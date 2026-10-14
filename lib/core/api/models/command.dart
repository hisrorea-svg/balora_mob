import 'package:freezed_annotation/freezed_annotation.dart';

part 'command.freezed.dart';
part 'command.g.dart';

/// The type of command being sent to Balora Desktop.
enum CommandType {
  @JsonValue('scan')
  scan,
  @JsonValue('add_product')
  addProduct,
  @JsonValue('update_product')
  updateProduct,
  @JsonValue('delete_product')
  deleteProduct,
  @JsonValue('inventory_scan')
  inventoryScan,
  @JsonValue('inventory_submit')
  inventorySubmit,
  @JsonValue('pos_scan')
  posScan,
}

/// A command queued for synchronization with Balora Desktop.
///
/// Commands follow the CQRS pattern — each represents a single
/// intent from the mobile device. They are persisted in the Drift
/// database queue and sent in priority order.
///
/// Example:
/// ```json
/// {
///   "commandId": "uuid-v4",
///   "type": "scan",
///   "barcode": "8901234567890",
///   "timestamp": "2026-07-04T10:00:00Z",
///   "deviceId": "uuid"
/// }
/// ```
@freezed
abstract class Command with _$Command {
  const factory Command({
    /// Unique identifier for this command (UUID v4).
    required String commandId,

    /// The type of command.
    required CommandType type,

    /// The scanned barcode value (nullable for non-scan commands).
    String? barcode,

    /// When this command was created on the device.
    required DateTime timestamp,

    /// The unique identifier of the sending device.
    required String deviceId,

    /// Optional payload for commands that need additional data
    /// (e.g., product updates, inventory submissions).
    Map<String, dynamic>? payload,
  }) = _Command;

  factory Command.fromJson(Map<String, dynamic> json) =>
      _$CommandFromJson(json);
}
