import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/bootstrap.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/models/pairing_payload.dart';
import '../../../core/providers.dart';
import '../../../core/result/result.dart';
import '../../../core/sync/database/app_database.dart';

part 'auth_repository.g.dart';

/// Repository responsible for pairing operations.
class AuthRepository {
  final ApiClient _apiClient;
  final AppDatabase _db;
  final WebSocketService _webSocket;

  AuthRepository(this._apiClient, this._db, this._webSocket);

  /// Decodes QR data (either a Balora Desktop pairing URL like
  /// `https://192.168.1.15:4784/m/?code=XXXX` or a JSON payload),
  /// validates it, and sends the pairing request to `/m/api/pair`.
  Future<Result<void>> pairWithQr(String rawQr, {String? deviceLabel}) async {
    try {
      final parsed = _extractPairingInput(rawQr, deviceLabel: deviceLabel);
      if (parsed == null) {
        return Failure(
          UnknownException(
            'رمز QR غير صالح أو لا يحتوي على كود ربط.',
            StackTrace.current,
          ),
        );
      }

      if (parsed.expiresAt != null &&
          parsed.expiresAt!.isBefore(DateTime.now())) {
        return Failure(
          UnknownException('انتهت صلاحية رمز الربط.', StackTrace.current),
        );
      }

      // Configure API client for the target desktop server.
      _apiClient.setBaseUrl(parsed.serverUrl);
      _apiClient.clearToken();

      // Call the Balora Desktop mobile pairing endpoint.
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/m/api/pair',
        data: {'code': parsed.code, 'label': parsed.label},
      );

      switch (response) {
        case Success(:final data):
          final envelopeData = data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data;

          final sessionToken =
              (envelopeData['token'] as String?) ??
              (envelopeData['sessionToken'] as String?);
          final deviceId =
              (envelopeData['sessionId'] as String?) ??
              (envelopeData['deviceId'] as String?);
          final serverLabel = (envelopeData['label'] as String?)?.trim();
          final expiresAtStr = envelopeData['expiresAt'] as String?;

          if (sessionToken == null ||
              deviceId == null ||
              expiresAtStr == null) {
            return Failure(
              UnknownException(
                'استجابة غير مكتملة من خادم الكمبيوتر.',
                StackTrace.current,
              ),
            );
          }

          final expiresAt = DateTime.parse(expiresAtStr);
          final effectiveName = (serverLabel != null && serverLabel.isNotEmpty)
              ? serverLabel
              : parsed.label;

          // Clear any old sessions.
          await _db.delete(_db.sessions).go();

          // Save the new session.
          await _db
              .into(_db.sessions)
              .insert(
                SessionsCompanion.insert(
                  sessionToken: sessionToken,
                  serverUrl: parsed.serverUrl,
                  deviceId: deviceId,
                  deviceName: effectiveName,
                  expiresAt: expiresAt,
                  createdAt: DateTime.now(),
                  isActive: const Value(true),
                ),
              );

          // Update ApiClient with the persistent session token and base URL.
          _apiClient.setBaseUrl(parsed.serverUrl);
          _apiClient.setToken(sessionToken);

          // Mark the HTTP session link as verified so connection indicators
          // across the app reflect the active session immediately.
          _webSocket.setSessionConnected(true);

          logger.i('Successfully paired with desktop. Session saved.');
          return const Success(null);

        case Failure(:final exception):
          logger.e('Pairing API failed: $exception');
          return Failure(exception);
      }
    } catch (e, st) {
      logger.e('Invalid QR Code data', error: e, stackTrace: st);
      return Failure(UnknownException('تنسيق رمز QR غير صالح: $e', st));
    }
  }

  /// Parses either a Desktop pairing URL (`https://ip:4784/m/?code=...`)
  /// or a JSON payload (`{"server": ..., "code"|"pairToken": ...}`).
  _ParsedPairingInput? _extractPairingInput(
    String rawQr, {
    String? deviceLabel,
  }) {
    final trimmed = rawQr.trim();
    if (trimmed.isEmpty) return null;

    final customLabel = deviceLabel?.trim();
    final defaultLabel = (customLabel != null && customLabel.isNotEmpty)
        ? customLabel
        : 'هاتف الصيدلية';

    // 1. Check if it's a URL (e.g. https://192.168.1.15:4784/m/?code=XXXX or 192.168.1.15:4784/m/?code=XXXX)
    final normalizedUrlCandidate =
        (!trimmed.startsWith('{') &&
            !trimmed.startsWith('http://') &&
            !trimmed.startsWith('https://') &&
            (trimmed.contains('/m/') || trimmed.contains('code=')))
        ? 'https://$trimmed'
        : trimmed;
    final uri = Uri.tryParse(normalizedUrlCandidate);
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty) {
      final code =
          (uri.queryParameters['code'] ??
                  uri.queryParameters['pairToken'] ??
                  uri.queryParameters['token'])
              ?.trim();
      if (code != null && code.isNotEmpty) {
        final serverUrl = '${uri.scheme}://${uri.authority}';
        final labelFromUrl = uri.queryParameters['label']?.trim();
        return _ParsedPairingInput(
          serverUrl: serverUrl,
          code: code,
          label: (customLabel != null && customLabel.isNotEmpty)
              ? customLabel
              : (labelFromUrl != null && labelFromUrl.isNotEmpty
                    ? labelFromUrl
                    : defaultLabel),
        );
      }
    }

    // 2. Fallback to JSON format (legacy PairingPayload or custom JSON)
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('pairToken') &&
            decoded.containsKey('server') &&
            decoded.containsKey('deviceName') &&
            decoded.containsKey('expiresAt')) {
          final payload = PairingPayload.fromJson(decoded);
          return _ParsedPairingInput(
            serverUrl: payload.server,
            code: payload.pairToken,
            label: (customLabel != null && customLabel.isNotEmpty)
                ? customLabel
                : payload.deviceName,
            expiresAt: payload.expiresAt,
          );
        }

        final server =
            (decoded['server'] as String? ?? decoded['url'] as String?)?.trim();
        final code =
            (decoded['code'] as String? ?? decoded['pairToken'] as String?)
                ?.trim();
        final labelJson =
            (decoded['label'] as String? ?? decoded['deviceName'] as String?)
                ?.trim();
        final expiresAtStr = decoded['expiresAt'] as String?;

        if (server != null &&
            server.isNotEmpty &&
            code != null &&
            code.isNotEmpty) {
          return _ParsedPairingInput(
            serverUrl: server,
            code: code,
            label: (customLabel != null && customLabel.isNotEmpty)
                ? customLabel
                : (labelJson != null && labelJson.isNotEmpty
                      ? labelJson
                      : defaultLabel),
            expiresAt: expiresAtStr != null
                ? DateTime.tryParse(expiresAtStr)
                : null,
          );
        }
      }
    }

    return null;
  }

  /// Returns the currently active, non-expired session, or `null`.
  ///
  /// As a side effect it wires the [ApiClient] (base URL + token) so callers
  /// can issue authenticated requests right after. If a session row exists
  /// but is expired, it is purged on the spot so the next call sees a clean
  /// slate (audit: BUG-A2 — previously expired sessions were treated as
  /// valid and left in the DB to keep resurrecting).
  Future<SessionEntry?> getActiveSession() async {
    final session = await _db.select(_db.sessions).getSingleOrNull();
    if (session == null) return null;
    if (!session.expiresAt.isAfter(DateTime.now())) {
      logger.w('Session expired (expiresAt=${session.expiresAt}) — purging.');
      await _db.delete(_db.sessions).go();
      _apiClient.clearAuth();
      return null;
    }
    _apiClient.setBaseUrl(session.serverUrl);
    _apiClient.setToken(session.sessionToken);
    return session;
  }

  /// Checks if there's an active, non-expired session in the database.
  Future<bool> hasActiveSession() async => (await getActiveSession()) != null;

  /// Gets the current device ID.
  Future<String?> getDeviceId() async => (await getActiveSession())?.deviceId;

  /// Verifies the persisted session token against `/m/api/session` on the
  /// Balora Desktop server and updates the live connection state.
  ///
  /// Returns `true` when the desktop confirms the session is active, `false`
  /// otherwise. If the server rejects the token with 401 (revoked or server
  /// restarted), the stale local session is purged automatically.
  Future<bool> connectFromActiveSession() async {
    final session = await getActiveSession();
    if (session == null) {
      _webSocket.setSessionConnected(false);
      return false;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/m/api/session',
    );

    switch (response) {
      case Success():
        _webSocket.setSessionConnected(true);
        return true;
      case Failure(:final exception):
        logger.w('Session check failed: $exception');
        if (exception is UnauthorizedException) {
          await unpair();
        } else {
          _webSocket.setSessionConnected(false);
        }
        return false;
    }
  }

  /// Clears the current session, purges the offline queue (which carries
  /// the old `deviceId` baked into each `commandJson`), and stands down the
  /// WebSocket so the desktop won't keep seeing a phantom connection.
  Future<void> unpair() async {
    await _webSocket.disconnect();
    await _db.delete(_db.queueItems).go();
    await _db.delete(_db.sessions).go();
    _apiClient.clearAuth();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(webSocketServiceProvider),
  );
}

class _ParsedPairingInput {
  final String serverUrl;
  final String code;
  final String label;
  final DateTime? expiresAt;

  const _ParsedPairingInput({
    required this.serverUrl,
    required this.code,
    required this.label,
    this.expiresAt,
  });
}
