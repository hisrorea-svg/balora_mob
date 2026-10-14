import 'package:drift/drift.dart';

/// Priority levels for queue items.
///
/// Determines the order in which commands are synced:
/// - High (0): Inventory operations — most critical
/// - Medium (1): Product updates
/// - Low (2): Telemetry, analytics
class QueuePriority {
  static const int high = 0;
  static const int medium = 1;
  static const int low = 2;
}

/// Status of a queue item.
class QueueStatus {
  /// Waiting to be sent.
  static const int pending = 0;

  /// Currently being sent to the server.
  static const int sending = 1;

  /// Successfully sent and ACK received.
  static const int completed = 2;

  /// Failed after all retries.
  static const int failed = 3;
}

/// The sync queue table — stores commands waiting to be
/// sent to Balora Desktop.
///
/// Items are fetched in priority order (high → low),
/// then by creation time (oldest first).
@DataClassName('QueueItemEntry')
class QueueItems extends Table {
  /// UUID v4 — matches the commandId.
  TextColumn get id => text()();

  /// Serialized JSON of the Command object.
  TextColumn get commandJson => text()();

  /// Command type (scan, add_product, etc.) for filtering.
  TextColumn get commandType => text()();

  /// Priority: 0=High, 1=Medium, 2=Low.
  IntColumn get priority =>
      integer().withDefault(const Constant(QueuePriority.medium))();

  /// Status: 0=pending, 1=sending, 2=completed, 3=failed.
  IntColumn get status =>
      integer().withDefault(const Constant(QueueStatus.pending))();

  /// Number of send attempts.
  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();

  /// Maximum retries before marking as failed.
  IntColumn get maxRetries =>
      integer().withDefault(const Constant(5))();

  /// Last error message (if any).
  TextColumn get lastError => text().nullable()();

  /// When this item was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When this item was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Stores the active pairing session.
@DataClassName('SessionEntry')
class Sessions extends Table {
  /// Auto-incremented ID.
  IntColumn get id => integer().autoIncrement()();

  /// The Balora Desktop server URL.
  TextColumn get serverUrl => text()();

  /// Session authentication token.
  TextColumn get sessionToken => text()();

  /// Unique device ID assigned by the server.
  TextColumn get deviceId => text()();

  /// Human-readable desktop name.
  TextColumn get deviceName => text()();

  /// When this session expires.
  DateTimeColumn get expiresAt => dateTime()();

  /// Comma-separated list of permissions.
  TextColumn get permissions => text().withDefault(const Constant(''))();

  /// Whether this is the currently active session.
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  /// When this session was created.
  DateTimeColumn get createdAt => dateTime()();
}

/// History of scanned barcodes for display and analytics.
@DataClassName('ScanHistoryEntry')
class ScanHistory extends Table {
  /// Auto-incremented ID.
  IntColumn get id => integer().autoIncrement()();

  /// The scanned barcode value.
  TextColumn get barcode => text()();

  /// Barcode format (ean13, qr, code128, etc.).
  TextColumn get format => text()();

  /// Product name (if resolved from server).
  TextColumn get productName => text().nullable()();

  /// Whether the scan was successfully synced.
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();

  /// Timestamp of the scan.
  DateTimeColumn get scannedAt => dateTime()();
}
