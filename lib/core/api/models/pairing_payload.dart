import 'package:freezed_annotation/freezed_annotation.dart';

part 'pairing_payload.freezed.dart';
part 'pairing_payload.g.dart';

/// Data extracted from the QR code displayed by Balora Desktop.
/// (Forced IDE re-analysis)
///
/// This payload contains everything the mobile app needs to
/// establish a secure connection with the desktop server.
///
/// Example QR content:
/// ```json
/// {
///   "server": "https://192.168.1.15:8080",
///   "pairToken": "xxxxx",
///   "deviceName": "Balora POS",
///   "expiresAt": "2026-07-05T10:00:00Z",
///   "version": 1
/// }
/// ```
@freezed
abstract class PairingPayload with _$PairingPayload {
  const factory PairingPayload({
    /// The base URL of the Balora Desktop server.
    required String server,

    /// One-time pairing token for authentication.
    required String pairToken,

    /// Human-readable name of the desktop device.
    required String deviceName,

    /// When this pairing token expires.
    required DateTime expiresAt,

    /// Protocol version for compatibility checks.
    @Default(1) int version,
  }) = _PairingPayload;

  factory PairingPayload.fromJson(Map<String, dynamic> json) =>
      _$PairingPayloadFromJson(json);
}

/// Response from the desktop after successful pairing.
@freezed
abstract class PairingResponse with _$PairingResponse {
  const factory PairingResponse({
    /// Session token for subsequent API calls.
    required String sessionToken,

    /// Unique identifier assigned to this device.
    required String deviceId,

    /// When this session expires.
    required DateTime expiresAt,

    /// Permissions granted to this device.
    @Default([]) List<String> permissions,
  }) = _PairingResponse;

  factory PairingResponse.fromJson(Map<String, dynamic> json) =>
      _$PairingResponseFromJson(json);
}
