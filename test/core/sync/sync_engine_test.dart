import 'dart:async';

import 'package:balora_mob/core/api/dio_client.dart';
import 'package:balora_mob/core/api/models/ack_response.dart';
import 'package:balora_mob/core/result/result.dart';
import 'package:balora_mob/core/services/connectivity_monitor.dart';
import 'package:balora_mob/core/services/websocket_service.dart';
import 'package:balora_mob/core/sync/database/app_database.dart';
import 'package:balora_mob/core/sync/database/daos/queue_dao.dart';
import 'package:balora_mob/core/sync/database/tables.dart';
import 'package:balora_mob/core/sync/queue_service.dart';
import 'package:balora_mob/core/sync/sync_engine.dart';
import 'package:balora_mob/core/sync/sync_status.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---
class MockApiClient extends Mock implements ApiClient {}
class MockConnectivityMonitor extends Mock implements ConnectivityMonitor {}
class MockWebSocketService extends Mock implements WebSocketService {}

void main() {
  late AppDatabase db;
  late QueueDao queueDao;
  late QueueService queueService;
  late MockApiClient apiClient;
  late MockConnectivityMonitor connectivity;
  late MockWebSocketService webSocket;
  late SyncEngine syncEngine;

  late StreamController<bool> connectivityController;
  late StreamController<AckResponse> ackController;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queueDao = QueueDao(db);
    queueService = QueueService(queueDao);
    
    apiClient = MockApiClient();
    connectivity = MockConnectivityMonitor();
    webSocket = MockWebSocketService();
    
    connectivityController = StreamController<bool>.broadcast();
    ackController = StreamController<AckResponse>.broadcast();

    when(() => connectivity.isConnected).thenReturn(true);
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);
    
    when(() => webSocket.onAck).thenAnswer((_) => ackController.stream);

    syncEngine = SyncEngine(
      queueDao: queueDao,
      apiClient: apiClient,
      connectivity: connectivity,
      webSocket: webSocket,
    );
  });

  tearDown(() async {
    syncEngine.dispose();
    await connectivityController.close();
    await ackController.close();
    await db.close();
  });

  group('SyncEngine Integration', () {
    test('syncNow processes items and marks them completed on success', () async {
      // 1. Enqueue a command
      final commandId = await queueService.enqueueScan(
        barcode: '123',
        deviceId: 'dev-1',
      );

      // 2. Mock successful API response
      when(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/commands',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Success({
            'commandId': commandId,
            'status': 'success',
          }));

      // 3. Initialize and trigger sync
      await syncEngine.initialize();
      
      // Wait a tiny bit for the async operations to settle
      await Future.delayed(Duration.zero);

      // 4. Verify item is removed from pending queue
      final count = await queueService.getPendingCount();
      expect(count, 0);
      
      // Verify API was called
      verify(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/commands',
            data: any(named: 'data'),
          )).called(1);
    });

    test('syncNow retries on failure and increments retryCount', () async {
      final commandId = await queueService.enqueueScan(
        barcode: '123',
        deviceId: 'dev-1',
      );

      // Mock network failure
      when(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/commands',
            data: any(named: 'data'),
          )).thenAnswer((_) async => const Failure(
            NetworkException('Timeout', stackTrace: StackTrace.empty),
          ));

      await syncEngine.initialize();
      await Future.delayed(Duration.zero);

      // Item should still be in queue
      final count = await queueService.getPendingCount();
      expect(count, 1);

      // Retry count should be 1
      final item = await queueDao.getById(commandId);
      expect(item!.retryCount, 1);
    });

    test('syncNow pauses when offline', () async {
      when(() => connectivity.isConnected).thenReturn(false);

      await queueService.enqueueScan(
        barcode: '123',
        deviceId: 'dev-1',
      );

      await syncEngine.initialize();
      await Future.delayed(Duration.zero);

      // Should not call API
      verifyNever(() => apiClient.post(any(), data: any(named: 'data')));
      
      expect(syncEngine.status, isA<SyncOffline>());
    });

    test('connectivity restoration triggers sync automatically', () async {
      when(() => connectivity.isConnected).thenReturn(false);

      final commandId = await queueService.enqueueScan(
        barcode: '123',
        deviceId: 'dev-1',
      );

      when(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/commands',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Success({
            'commandId': commandId,
            'status': 'success',
          }));

      await syncEngine.initialize();
      expect(syncEngine.status, isA<SyncOffline>());

      // Simulate connection restored
      when(() => connectivity.isConnected).thenReturn(true);
      connectivityController.add(true);

      // Wait for stream to process and sync to run
      await Future.delayed(const Duration(milliseconds: 50));

      // Should have synced and emptied queue
      final count = await queueService.getPendingCount();
      expect(count, 0);
      expect(syncEngine.status, isA<SyncIdle>());
    });

    test('onCommandFailed stream emits when server rejects command', () async {
      final commandId = await queueService.enqueueScan(
        barcode: '123',
        deviceId: 'dev-1',
      );

      // Mock server rejection
      when(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/commands',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Success({
            'commandId': commandId,
            'status': 'failure',
            'message': 'Invalid barcode',
          }));

      // Listen for failure
      final failureFuture = syncEngine.onCommandFailed.first;

      await syncEngine.initialize();
      
      final failedAck = await failureFuture;
      
      expect(failedAck.commandId, commandId);
      expect(failedAck.status, AckStatus.failure);
      expect(failedAck.message, 'Invalid barcode');

      // The item should be marked as failed in DB
      final item = await queueDao.getById(commandId);
      expect(item!.status, QueueStatus.failed);
    });

    test('initialize resets stuck sending items to pending', () async {
      // Direct insertion to bypass QueueService logic
      const commandId = 'stuck-123';
      await queueDao.enqueue(QueueItemsCompanion.insert(
        id: commandId,
        commandJson: '{}',
        commandType: 'scan',
        priority: const drift.Value(QueuePriority.medium),
        status: const drift.Value(QueueStatus.sending), // Stuck in sending
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Mock API so it succeeds when picked up
      when(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/commands',
            data: any(named: 'data'),
          )).thenAnswer((_) async => const Success({
            'commandId': commandId,
            'status': 'success',
          }));

      await syncEngine.initialize();
      await Future.delayed(Duration.zero);

      // It should have been picked up and processed successfully
      final count = await queueService.getPendingCount();
      expect(count, 0);
      
      verify(() => apiClient.post<Map<String, dynamic>>(any(), data: any(named: 'data'))).called(1);
    });
  });
}

