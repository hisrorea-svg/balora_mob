// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';


import '../../app/bootstrap.dart';
import '../api/dio_client.dart';
import '../api/models/ack_response.dart';
import '../result/result.dart';
import '../services/connectivity_monitor.dart';
import '../services/websocket_service.dart';
import 'database/app_database.dart';
import 'database/daos/queue_dao.dart';
import 'sync_status.dart';

/// The core sync engine — orchestrates sending queued
/// commands to Balora Desktop.
///
/// **Sync Triggers:**
/// 1. App Resume
/// 2. Connectivity Restored
/// 3. Manual Sync
/// 4. New Item Enqueued
///
/// **Priority Order:** High → Medium → Low
///
/// **Lifecycle:**
/// ```
/// Item enqueued → pending
///   ↓
/// Sync picks item → sending
///   ↓
/// POST to Desktop → wait for ACK
///   ↓ success           ↓ failure
/// completed → remove   retry (or failed if max)
/// ```
class SyncEngine {
  final QueueDao _queueDao;
  final ApiClient _apiClient;
  final ConnectivityMonitor _connectivity;
  final WebSocketService _webSocket;

  final _statusController = StreamController<SyncStatus>.broadcast();
  final _failedCommandsController = StreamController<AckResponse>.broadcast();
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<AckResponse>? _ackSub;
  StreamSubscription<int>? _queueSub;

  bool _isSyncing = false;
  SyncStatus _currentStatus = const SyncStatus.idle();

  SyncEngine({
    required QueueDao queueDao,
    required ApiClient apiClient,
    required ConnectivityMonitor connectivity,
    required WebSocketService webSocket,
  })  : _queueDao = queueDao,
        _apiClient = apiClient,
        _connectivity = connectivity,
        _webSocket = webSocket;

  /// Current sync status.
  SyncStatus get status => _currentStatus;

  /// Stream of sync status changes.
  Stream<SyncStatus> get onStatusChanged => _statusController.stream;

  /// Stream of failed commands for optimistic UI reversion.
  Stream<AckResponse> get onCommandFailed => _failedCommandsController.stream;

  /// Initializes the sync engine.
  ///
  /// Must be called once at app startup (after pairing).
  Future<void> initialize() async {
    // The WebSocket connection itself is established by the splash/lifecycle
    // flow via `AuthRepository.connectFromActiveSession`. Here we only
    // register ACK listeners and recover stuck items — we no longer open a
    // *unauthenticated* WS that would confuse the desktop.

    // Recover any items stuck in "sending" state from a crash.
    await _queueDao.resetStuckItems();

    // Listen for connectivity changes.
    _connectivitySub = _connectivity.onConnectivityChanged.listen((connected) {
      if (connected) {
        logger.i('📡 Connection restored — triggering sync');
        syncNow();
      } else {
        _updateStatus(const SyncStatus.offline());
      }
    });

    // Listen for WebSocket ACKs.
    _ackSub = _webSocket.onAck.listen(_handleAck);

    // Listen for queue additions to trigger sync automatically.
    _queueSub = _queueDao.watchPendingCount().listen((count) {
      if (count > 0 && !_isSyncing && _connectivity.isConnected) {
        syncNow();
      }
    });

    // Initial sync if connected (fire and forget so we don't block app startup)
    if (_connectivity.isConnected) {
      syncNow();
    } else {
      _updateStatus(const SyncStatus.offline());
    }

    logger.i('⚡ Sync engine initialized');
  }

  /// Re-triggers a sync cycle. Called by the app-lifecycle observer on
  /// resume and by [connectFromActiveSession] flows.
  Future<void> onPossiblyConnected() async {
    if (_connectivity.isConnected) {
      await syncNow();
    } else {
      _updateStatus(const SyncStatus.offline());
    }
  }

  /// Triggers a sync cycle.
  ///
  /// Safe to call multiple times — won't overlap.
  Future<void> syncNow() async {
    if (_isSyncing) return;
    if (!_connectivity.isConnected) {
      _updateStatus(const SyncStatus.offline());
      return;
    }

    _isSyncing = true;

    try {
      final pending = await _queueDao.getPendingItems();
      if (pending.isEmpty) {
        _updateStatus(const SyncStatus.idle());
        return;
      }

      final total = pending.length;
      logger.i('🔄 Syncing $total items...');

      for (var i = 0; i < pending.length; i++) {
        if (!_connectivity.isConnected) {
          _updateStatus(const SyncStatus.offline());
          break;
        }

        _updateStatus(SyncStatus.syncing(
          pending: pending.length - i,
          total: total,
        ));

        await _syncItem(pending[i]);
      }

      // Check if all done.
      final remaining = await _queueDao.getPendingCount();
      if (remaining == 0) {
        _updateStatus(const SyncStatus.idle());
        logger.i('✅ Sync complete — queue empty');
      }
    } on Exception catch (e) {
      _updateStatus(SyncStatus.error(message: e.toString()));
      logger.e('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Cleans up resources.
  void dispose() {
    _connectivitySub?.cancel();
    _ackSub?.cancel();
    _queueSub?.cancel();
    _statusController.close();
    _failedCommandsController.close();
  }

  /// Syncs a single queue item to Balora Desktop.
  Future<void> _syncItem(QueueItemEntry item) async {
    // Mark as sending.
    await _queueDao.markSending(item.id);

    // Parse the command JSON.
    final commandData =
        jsonDecode(item.commandJson) as Map<String, dynamic>;

    // POST to desktop mobile listener commands endpoint.
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/m/api/commands',
      data: commandData,
    );

    switch (result) {
      case Success(:final data):
        final ackPayload =
            (data['commandId'] != null && data['status'] != null)
                ? data
                : (data['data'] is Map<String, dynamic>
                    ? data['data'] as Map<String, dynamic>
                    : data);
        final ack = AckResponse.fromJson(ackPayload);
        await _processAck(ack);

      case Failure(:final exception):
        logger.w('⚠️ Sync failed for ${item.id}: $exception');
        if (exception is UnauthorizedException) {
          // Don't retry auth failures.
          await _queueDao.markFailed(item.id, 'Unauthorized');
        } else {
          await _queueDao.markRetry(item.id);
        }
    }
  }

  /// Handles an ACK response (from REST or WebSocket).
  Future<void> _handleAck(AckResponse ack) async {
    await _processAck(ack);

    // Check if there are more items to sync.
    final remaining = await _queueDao.getPendingCount();
    if (remaining > 0 && !_isSyncing) {
      await syncNow();
    }
  }

  /// Processes an ACK response.
  Future<void> _processAck(AckResponse ack) async {
    switch (ack.status) {
      case AckStatus.success:
        await _queueDao.markCompleted(ack.commandId);
        await _queueDao.removeCompleted(ack.commandId);
        logger.d('✅ ACK success: ${ack.commandId}');

      case AckStatus.failure:
        await _queueDao.markFailed(
          ack.commandId,
          ack.message ?? 'Server rejected command',
        );
        logger.w('❌ ACK failure: ${ack.commandId} — ${ack.message}');
        _failedCommandsController.add(ack); // Emit event for Optimistic UI revert.

      case AckStatus.pending:
        // Server is still processing — do nothing, wait for final ACK.
        logger.d('⏳ ACK pending: ${ack.commandId}');
    }
  }

  void _updateStatus(SyncStatus newStatus) {
    _currentStatus = newStatus;
    _statusController.add(newStatus);
  }
}
