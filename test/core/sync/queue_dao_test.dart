import 'dart:convert';

import 'package:balora_mob/core/api/models/command.dart';
import 'package:balora_mob/core/sync/database/app_database.dart';
import 'package:balora_mob/core/sync/database/daos/queue_dao.dart';
import 'package:balora_mob/core/sync/database/tables.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late QueueDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = QueueDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  const uuid = Uuid();

  QueueItemsCompanion _createMockItem({
    int priority = QueuePriority.medium,
    int status = QueueStatus.pending,
    DateTime? createdAt,
  }) {
    final commandId = uuid.v4();
    final command = Command(
      commandId: commandId,
      type: CommandType.scan,
      barcode: '123456789',
      timestamp: createdAt ?? DateTime.now(),
      deviceId: 'device-1',
    );

    return QueueItemsCompanion(
      id: Value(commandId),
      commandJson: Value(jsonEncode(command.toJson())),
      commandType: Value(command.type.name),
      priority: Value(priority),
      status: Value(status),
      createdAt: Value(createdAt ?? DateTime.now()),
      updatedAt: Value(createdAt ?? DateTime.now()),
    );
  }

  group('QueueDao CRUD Operations', () {
    test('enqueue should insert an item into the database', () async {
      final item = _createMockItem();
      await dao.enqueue(item);

      final result = await dao.getById(item.id.value);
      expect(result, isNotNull);
      expect(result!.id, item.id.value);
    });

    test(
      'getPendingItems should return items sorted by priority then time',
      () async {
        final now = DateTime.now();

        // Enqueue items out of order
        await dao.enqueue(
          _createMockItem(
            priority: QueuePriority.low,
            createdAt: now.add(const Duration(seconds: 1)),
          ),
        );

        final highPriorityId = uuid.v4();
        await dao.enqueue(
          QueueItemsCompanion.insert(
            id: highPriorityId,
            commandJson: '{}',
            commandType: 'scan',
            priority: const Value(QueuePriority.high),
            createdAt: now,
            updatedAt: now,
          ),
        );

        final mediumPriorityOldId = uuid.v4();
        await dao.enqueue(
          QueueItemsCompanion.insert(
            id: mediumPriorityOldId,
            commandJson: '{}',
            commandType: 'scan',
            priority: const Value(QueuePriority.medium),
            createdAt: now.subtract(const Duration(minutes: 5)), // Older
            updatedAt: now,
          ),
        );

        final mediumPriorityNewId = uuid.v4();
        await dao.enqueue(
          QueueItemsCompanion.insert(
            id: mediumPriorityNewId,
            commandJson: '{}',
            commandType: 'scan',
            priority: const Value(QueuePriority.medium),
            createdAt: now, // Newer
            updatedAt: now,
          ),
        );

        final pending = await dao.getPendingItems();
        expect(pending.length, 4);

        // Order: High -> Medium (Old) -> Medium (New) -> Low
        expect(pending[0].id, highPriorityId);
        expect(pending[1].id, mediumPriorityOldId);
        expect(pending[2].id, mediumPriorityNewId);
        expect(pending[3].priority, QueuePriority.low);
      },
    );

    test('markSending updates the status to sending', () async {
      final item = _createMockItem();
      await dao.enqueue(item);

      await dao.markSending(item.id.value);

      final updated = await dao.getById(item.id.value);
      expect(updated!.status, QueueStatus.sending);
    });

    test('markCompleted updates the status to completed', () async {
      final item = _createMockItem();
      await dao.enqueue(item);

      await dao.markCompleted(item.id.value);

      final updated = await dao.getById(item.id.value);
      expect(updated!.status, QueueStatus.completed);
    });

    test('markRetry increments retryCount or fails if max reached', () async {
      final item = _createMockItem();
      await dao.enqueue(item);

      // First retry
      await dao.markRetry(item.id.value);
      var updated = await dao.getById(item.id.value);
      expect(updated!.retryCount, 1);
      expect(updated.status, QueueStatus.pending);

      // Max out retries (default max is 5)
      for (var i = 0; i < 4; i++) {
        await dao.markRetry(item.id.value);
      }

      updated = await dao.getById(item.id.value);
      expect(updated!.retryCount, 4);
      expect(updated.status, QueueStatus.failed);
      expect(updated.lastError, 'Max retries exceeded');
    });

    test('resetStuckItems reverts sending items to pending', () async {
      final item1 = _createMockItem(status: QueueStatus.sending);
      final item2 = _createMockItem(status: QueueStatus.pending);

      await dao.enqueue(item1);
      await dao.enqueue(item2);

      await dao.resetStuckItems();

      final pendingCount = await dao.getPendingCount();
      expect(pendingCount, 2);
    });
    test(
      'watchPendingCount emits correct count when items are added or removed',
      () async {
        final stream = dao.watchPendingCount();

        // We expect it to emit 0 initially, then 1 after we enqueue.
        expectLater(stream, emitsInOrder([0, 1]));

        // Wait a tiny bit for the initial emit to process (Drift needs event loop)
        await Future.delayed(Duration.zero);

        // Add item -> 1
        final item1 = _createMockItem();
        await dao.enqueue(item1);
      },
    );

    test('deleteItem removes item from database', () async {
      final item = _createMockItem();
      await dao.enqueue(item);

      var pending = await dao.getPendingItems();
      expect(pending.length, 1);

      await dao.deleteItem(item.id.value);

      pending = await dao.getPendingItems();
      expect(pending.isEmpty, true);
    });

    test('removeCompleted removes only completed items', () async {
      final item1 = _createMockItem(status: QueueStatus.completed);
      final item2 = _createMockItem(status: QueueStatus.pending);

      await dao.enqueue(item1);
      await dao.enqueue(item2);

      await dao.removeCompleted(item1.id.value);

      final result1 = await dao.getById(item1.id.value);
      final result2 = await dao.getById(item2.id.value);

      expect(result1, isNull);
      expect(result2, isNotNull);
    });
  });
}
