import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'queue_dao.g.dart';

/// Data Access Object for the sync queue.
///
/// Provides all CRUD operations and specialized queries
/// for the priority-based offline queue.
@DriftAccessor(tables: [QueueItems])
class QueueDao extends DatabaseAccessor<AppDatabase> with _$QueueDaoMixin {
  QueueDao(super.db);

  // ─── Insert ──────────────────────────────────────

  /// Adds a new command to the queue.
  Future<void> enqueue(QueueItemsCompanion item) {
    return into(queueItems).insert(item);
  }

  // ─── Read ────────────────────────────────────────

  /// Returns all pending items ordered by priority (high first),
  /// then by creation time (oldest first).
  Future<List<QueueItemEntry>> getPendingItems() {
    return (select(queueItems)
          ..where((t) => t.status.equals(QueueStatus.pending))
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  /// Watches all pending items ordered by priority and time.
  Stream<List<QueueItemEntry>> watchPendingItems() {
    return (select(queueItems)
          ..where((t) => t.status.equals(QueueStatus.pending))
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch();
  }

  /// Returns the next item to sync (highest priority, oldest).
  Future<QueueItemEntry?> getNextPending() {
    return (select(queueItems)
          ..where((t) => t.status.equals(QueueStatus.pending))
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Returns all items with the given status.
  Future<List<QueueItemEntry>> getByStatus(int status) {
    return (select(queueItems)..where((t) => t.status.equals(status))).get();
  }

  /// Returns the total count of pending items.
  Future<int> getPendingCount() async {
    final count = countAll();
    final query = selectOnly(queueItems)
      ..where(queueItems.status.equals(QueueStatus.pending))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Returns a specific item by its commandId.
  Future<QueueItemEntry?> getById(String id) {
    return (select(
      queueItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watches pending count reactively.
  Stream<int> watchPendingCount() {
    final count = countAll();
    final query = selectOnly(queueItems)
      ..where(queueItems.status.equals(QueueStatus.pending))
      ..addColumns([count]);
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  // ─── Update ──────────────────────────────────────

  /// Marks an item as currently being sent.
  Future<void> markSending(String id) {
    return (update(queueItems)..where((t) => t.id.equals(id))).write(
      QueueItemsCompanion(
        status: const Value(QueueStatus.sending),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks an item as completed (ACK received).
  Future<void> markCompleted(String id) {
    return (update(queueItems)..where((t) => t.id.equals(id))).write(
      QueueItemsCompanion(
        status: const Value(QueueStatus.completed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks an item as failed with an error message.
  Future<void> markFailed(String id, String error) {
    return (update(queueItems)..where((t) => t.id.equals(id))).write(
      QueueItemsCompanion(
        status: const Value(QueueStatus.failed),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Increments the retry count and resets status to pending.
  Future<void> markRetry(String id) async {
    final item = await getById(id);
    if (item == null) return;

    final newRetryCount = item.retryCount + 1;
    if (newRetryCount >= item.maxRetries) {
      await markFailed(id, 'Max retries exceeded');
      return;
    }

    await (update(queueItems)..where((t) => t.id.equals(id))).write(
      QueueItemsCompanion(
        status: const Value(QueueStatus.pending),
        retryCount: Value(newRetryCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ─── Delete ──────────────────────────────────────

  /// Removes a completed item from the queue.
  Future<void> removeCompleted(String id) {
    return (delete(queueItems)..where(
          (t) => t.id.equals(id) & t.status.equals(QueueStatus.completed),
        ))
        .go();
  }

  /// Removes an item completely, regardless of status.
  Future<void> deleteItem(String id) {
    return (delete(queueItems)..where((t) => t.id.equals(id))).go();
  }

  /// Removes all completed items.
  Future<void> clearCompleted() {
    return (delete(
      queueItems,
    )..where((t) => t.status.equals(QueueStatus.completed))).go();
  }

  /// Resets all "sending" items back to "pending".
  /// Called on app startup to recover from crashes.
  Future<void> resetStuckItems() {
    return (update(
      queueItems,
    )..where((t) => t.status.equals(QueueStatus.sending))).write(
      QueueItemsCompanion(
        status: const Value(QueueStatus.pending),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
