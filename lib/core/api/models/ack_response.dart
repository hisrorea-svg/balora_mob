import 'package:freezed_annotation/freezed_annotation.dart';

part 'ack_response.freezed.dart';
part 'ack_response.g.dart';

/// The status of an ACK from Balora Desktop.
enum AckStatus {
  /// The command was processed successfully.
  @JsonValue('success')
  success,

  /// The command failed (business rule rejection, validation error, etc.).
  @JsonValue('failure')
  failure,

  /// The command was received but is still being processed.
  @JsonValue('pending')
  pending,
}

/// Server acknowledgment for a command sent from mobile.
///
/// When Balora Desktop processes a command from the sync queue,
/// it responds with an ACK containing the original [commandId]
/// and a [status] indicating the result.
///
/// On [AckStatus.failure], the Optimistic UI state is reverted
/// and the user is notified with the [message].
///
/// Example:
/// ```json
/// {
///   "commandId": "uuid-v4",
///   "status": "success",
///   "message": null,
///   "data": null
/// }
/// ```
@freezed
abstract class AckResponse with _$AckResponse {
  const factory AckResponse({
    /// The commandId this ACK corresponds to.
    required String commandId,

    /// The result status.
    required AckStatus status,

    /// Optional message (e.g., error description on failure).
    String? message,

    /// Optional response data from the server.
    Map<String, dynamic>? data,
  }) = _AckResponse;

  factory AckResponse.fromJson(Map<String, dynamic> json) =>
      _$AckResponseFromJson(json);
}
