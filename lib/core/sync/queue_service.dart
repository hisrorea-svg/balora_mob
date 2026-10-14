import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../app/bootstrap.dart';
import '../api/models/command.dart';
import 'database/app_database.dart';
import 'database/daos/queue_dao.dart';
import 'database/tables.dart';

const _uuid = Uuid();

/// Service for enqueuing commands into the sync queue.
///
/// This is the primary interface used by features (Scanner,
/// Products, Inventory) to schedule operations for sync.
///
/// Usage:
/// ```dart
/// final queueService = ref.read(queueServiceProvider);
/// await queueService.enqueueScan(barcode: '6281000000101', deviceId: deviceId);
/// ```
class QueueService {
  final QueueDao _dao;

  QueueService(this._dao);

  /// Enqueues a scan command (high priority).
  Future<String> enqueueScan({
    required String barcode,
    required String deviceId,
  }) {
    final command = Command(
      commandId: _uuid.v4(),
      type: CommandType.scan,
      barcode: barcode,
      timestamp: DateTime.now(),
      deviceId: deviceId,
    );
    return _enqueue(command, QueuePriority.high);
  }

  /// Enqueues a product add command (medium priority).
  Future<String> enqueueAddProduct({
    required String deviceId,
    required Map<String, dynamic> productData,
  }) {
    final command = Command(
      commandId: _uuid.v4(),
      type: CommandType.addProduct,
      timestamp: DateTime.now(),
      deviceId: deviceId,
      payload: productData,
    );
    return _enqueue(command, QueuePriority.medium);
  }

  /// Enqueues a product update command (medium priority).
  Future<String> enqueueUpdateProduct({
    required String deviceId,
    required Map<String, dynamic> productData,
  }) {
    final command = Command(
      commandId: _uuid.v4(),
      type: CommandType.updateProduct,
      timestamp: DateTime.now(),
      deviceId: deviceId,
      payload: productData,
    );
    return _enqueue(command, QueuePriority.medium);
  }

  /// Enqueues a generic command based on type.
  Future<String> enqueueCommand({
    required CommandType type,
    required String deviceId,
    String? barcode,
    Map<String, dynamic>? payload,
    int priority = QueuePriority.medium,
  }) {
    final command = Command(
      commandId: _uuid.v4(),
      type: type,
      barcode: barcode,
      timestamp: DateTime.now(),
      deviceId: deviceId,
      payload: payload,
    );
    return _enqueue(command, priority);
  }

  /// Enqueues an inventory scan command (high priority).
  Future<String> enqueueInventoryScan({
    required String barcode,
    required String deviceId,
    required String sessionId,
  }) {
    final command = Command(
      commandId: _uuid.v4(),
      type: CommandType.inventoryScan,
      barcode: barcode,
      timestamp: DateTime.now(),
      deviceId: deviceId,
      payload: {'sessionId': sessionId},
    );
    return _enqueue(command, QueuePriority.high);
  }

  /// Enqueues an inventory submission command (high priority).
  Future<String> enqueueInventorySubmit({
    required String deviceId,
    required Map<String, dynamic> inventoryData,
  }) {
    final command = Command(
      commandId: _uuid.v4(),
      type: CommandType.inventorySubmit,
      timestamp: DateTime.now(),
      deviceId: deviceId,
      payload: inventoryData,
    );
    return _enqueue(command, QueuePriority.high);
  }

  /// Returns the count of pending items.
  Future<int> getPendingCount() => _dao.getPendingCount();

  /// Watches the pending count reactively.
  Stream<int> watchPendingCount() => _dao.watchPendingCount();

  Future<String> _enqueue(Command command, int priority) async {
    final now = DateTime.now();
    await _dao.enqueue(
      QueueItemsCompanion(
        id: Value(command.commandId),
        commandJson: Value(jsonEncode(command.toJson())),
        commandType: Value(command.type.name),
        priority: Value(priority),
        status: const Value(QueueStatus.pending),
        retryCount: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    logger.d(
      '📝 Enqueued: ${command.type.name} '
      '(id: ${command.commandId}, priority: $priority)',
    );

    return command.commandId;
  }
}


