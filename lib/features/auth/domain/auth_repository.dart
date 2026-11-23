import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/bootstrap.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/models/pairing_payload.dart';
import '../../../core/providers.dart';
import '../../../core/result/result.dart';
import '../../../core/security/secure_session_store.dart';
import '../../../core/security/server_certificate_pins.dart';
import '../../../core/sync/database/app_database.dart';

part 'auth_repository.g.dart';

/// Repository responsible for pairing operations.
///
/// The session token itself is never stored in the Drift database —
/// it lives in secure storage via [SessionTokenStore]. The `Sessions`
/// table keeps only the non-secret session metadata, and its legacy
/// `sessionToken` column is always written empty (any value left there
/// by an older app version is migrated to secure storage and cleared
/// on first read).
class AuthRepository {
  final ApiClient _apiClient;
  final AppDatabase _db;
  final WebSocketService _webSocket;
  final SessionTokenStore _tokenStore;

  AuthRepository(
    this._apiClient,
    this._db,
    this._webSocket, {
    SessionTokenStore? tokenStore,
  }) : _tokenStore = tokenStore ?? SecureSessionTokenStore();

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

      return await _completePairing(
        serverUrl: parsed.serverUrl,
        code: parsed.code,
        label: parsed.label,
      );
    } catch (e, st) {
      logger.e('Invalid QR Code data', error: e, stackTrace: st);
      return Failure(UnknownException('تنسيق رمز QR غير صالح: $e', st));
    }
  }

  /// Pairs with a desktop using a 6-digit code typed by the user
  /// (the YouTube-style alternative to scanning the QR code).
  ///
  /// The code alone carries no server address, so [serverUrl] must be
  /// supplied separately (last-used server, a discovered server, or a
  /// manually typed address). The request, the response parsing and the
  /// session saving are exactly the same as [pairWithQr] — see
  /// [_completePairing].
  Future<Result<void>> pairWithCode({
    required String serverUrl,
    required String code,
    String? deviceLabel,
  }) async {
    final cleanCode = code.trim();
    if (!isSixDigitCode(cleanCode)) {
      return Failure(
        UnknownException('كود الربط لازم يكون 6 أرقام.', StackTrace.current),
      );
    }
    final normalizedServer = _normalizeServerUrl(serverUrl);
    if (normalizedServer == null) {
      return Failure(
        UnknownException('عنوان الكمبيوتر غير صالح.', StackTrace.current),
      );
    }
    try {
      return await _completePairing(
        serverUrl: normalizedServer,
        code: cleanCode,
        label: _resolveLabel(deviceLabel),
      );
    } catch (e, st) {
      logger.e('Pairing by code failed', error: e, stackTrace: st);
      return Failure(UnknownException('فشل الربط بالكود: $e', st));
    }
  }

  /// Whether [code] is a well-formed 6-digit linking code. Shared by
  /// the repository and the controller so a malformed code is rejected
  /// before any network call.
  static bool isSixDigitCode(String code) =>
      RegExp(r'^\d{6}$').hasMatch(code);

  static String _resolveLabel(String? deviceLabel) {
    final custom = deviceLabel?.trim();
    return (custom != null && custom.isNotEmpty)
        ? custom
        : 'هاتف الصيدلية';
  }

  /// Normalizes a typed server address (`192.168.1.15:4784`,
  /// `https://192.168.1.15:4784`) into a base URL, or `null` when it
  /// cannot be parsed.
  static String? _normalizeServerUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final candidate =
        (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(candidate);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return '${uri.scheme}://${uri.authority}';
  }

  /// The shared pairing exchange used by both [pairWithQr] and
  /// [pairWithCode]: posts `{code, label}` to `/m/api/pair`, pins the
  /// desktop's certificate on first contact, and saves the session
  /// (token in secure storage, metadata in the database).
  Future<Result<void>> _completePairing({
    required String serverUrl,
    required String code,
    required String label,
  }) async {
    // Configure API client for the target desktop server.
    _apiClient.setBaseUrl(serverUrl);
    _apiClient.clearToken();

    // The desktop may have regenerated its TLS certificate since the
    // last pairing. Forget any stored pin for this host so the
    // certificate presented by this pairing is pinned instead of
    // being rejected as a mismatch (see ServerCertificatePins).
    await _forgetPinFor(serverUrl);

    // Call the Balora Desktop mobile pairing endpoint.
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/m/api/pair',
      data: {'code': code, 'label': label},
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
            : label;

        // Clear any old sessions.
        await _db.delete(_db.sessions).go();
        await _tokenStore.deleteToken();

        // Store the token in secure storage first: if that fails,
        // pairing fails instead of leaving a session row behind
        // with no usable token.
        await _tokenStore.writeToken(sessionToken);

        // Save the new session. The legacy `sessionToken` column
        // is deliberately left empty — the token lives only in
        // secure storage (see the Sessions table docs).
        await _db
            .into(_db.sessions)
            .insert(
              SessionsCompanion.insert(
                sessionToken: '',
                serverUrl: serverUrl,
                deviceId: deviceId,
                deviceName: effectiveName,
                expiresAt: expiresAt,
                createdAt: DateTime.now(),
                isActive: const Value(true),
              ),
            );

        // Update ApiClient with the persistent session token and base URL.
        _apiClient.setBaseUrl(serverUrl);
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
  ///
  /// The token is read from secure storage, not from the session row.
  /// A token left in the row by an older app version is migrated to
  /// secure storage and cleared from the row. If no token can be
  /// found anywhere, the session is unusable and is purged.
  ///
  /// A transient failure to read secure storage is different from a
  /// missing token: the row is kept and `null` is returned, so the
  /// next launch can retry instead of forcing the user to re-pair
  /// for a token that is still stored.
  Future<SessionEntry?> getActiveSession() async {
    final session = await _db.select(_db.sessions).getSingleOrNull();
    if (session == null) return null;
    if (!session.expiresAt.isAfter(DateTime.now())) {
      logger.w('Session expired (expiresAt=${session.expiresAt}) — purging.');
      await _db.delete(_db.sessions).go();
      await _deleteTokenBestEffort();
      _apiClient.clearAuth();
      return null;
    }
    final String? token;
    try {
      token = await _readSessionToken(session);
    } on _TokenReadFailed {
      logger.w(
        'Could not read session token — keeping session for retry.',
      );
      return null;
    }
    if (token == null || token.isEmpty) {
      logger.w('Session row without a stored token — purging.');
      await _db.delete(_db.sessions).go();
      _apiClient.clearAuth();
      return null;
    }
    _apiClient.setBaseUrl(session.serverUrl);
    _apiClient.setToken(token);
    return session;
  }

  /// Reads the session token from secure storage, migrating a legacy
  /// plain-text token out of the session row if one is still there.
  ///
  /// Returns `null` only when the token is genuinely absent. When
  /// secure storage itself cannot be read or written, throws
  /// [_TokenReadFailed] instead, so the caller can keep the session
  /// row for a later retry rather than purging it.
  Future<String?> _readSessionToken(SessionEntry session) async {
    final String? stored;
    try {
      stored = await _tokenStore.readToken();
    } catch (e) {
      logger.e('Could not read session token from secure storage: $e');
      throw const _TokenReadFailed();
    }
    if (stored != null && stored.isNotEmpty) {
      // A legacy plain-text token may still sit in the row even
      // though secure storage already has one — clear it from disk.
      // Clearing is best-effort: failing to clear must not invalidate
      // a token we already hold.
      if (session.sessionToken.isNotEmpty) {
        await _clearLegacyToken(session);
      }
      return stored;
    }
    if (session.sessionToken.isEmpty) return null;
    // Older app version: move the plain-text token into secure storage
    // and clear it from the database so it is not left on disk.
    try {
      await _tokenStore.writeToken(session.sessionToken);
    } catch (e) {
      logger.e('Could not migrate legacy session token: $e');
      throw const _TokenReadFailed();
    }
    await _clearLegacyToken(session);
    return session.sessionToken;
  }

  /// Clears the legacy plain-text token from the session row, if any.
  /// Best-effort: a failure here only logs, it never fails the caller.
  Future<void> _clearLegacyToken(SessionEntry session) async {
    if (session.sessionToken.isEmpty) return;
    try {
      await (_db.update(
        _db.sessions,
      )..where((t) => t.id.equals(session.id))).write(
        const SessionsCompanion(sessionToken: Value('')),
      );
    } catch (e) {
      logger.w('Could not clear legacy session token from database: $e');
    }
  }

  /// Deletes the token from secure storage, logging instead of throwing
  /// when storage is unavailable (used on purge/unpair paths, where a
  /// storage failure must not leave a stale session behind or crash
  /// the caller).
  Future<void> _deleteTokenBestEffort() async {
    try {
      await _tokenStore.deleteToken();
    } catch (e) {
      logger.w('Could not delete session token from secure storage: $e');
    }
  }

  /// Forgets the pinned certificate for [serverUrl], if any, without
  /// failing the caller's flow when secure storage is unavailable
  /// (for example in unit tests without a platform channel).
  Future<void> _forgetPinFor(String serverUrl) async {
    final hostPort = _hostPort(serverUrl);
    if (hostPort == null) return;
    try {
      await ServerCertificatePins.instance.forget(
        hostPort.host,
        hostPort.port,
      );
    } catch (e) {
      logger.w('Could not forget old certificate pin: $e');
    }
  }

  static ({String host, int port})? _hostPort(String serverUrl) {
    final uri = Uri.tryParse(serverUrl);
    if (uri == null || uri.host.isEmpty) return null;
    return (
      host: uri.host,
      port: uri.hasPort
          ? uri.port
          : uri.scheme == 'http'
          ? 80
          : 443,
    );
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
  ///
  /// Sliding renewal: when a successful check carries a refreshed
  /// `expiresAt`, it is persisted to the session row, so an actively
  /// used device keeps its session alive without re-pairing. A
  /// response without a usable expiry leaves the stored one untouched.
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
      case Success(:final data):
        await _refreshExpiryIfProvided(session, data);
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

  /// Persists a refreshed `expiresAt` from a successful session check.
  /// Ignored when the response carries no usable expiry — the stored
  /// one stays. Never shortens the session from a stale value: only an
  /// expiry in the future is written.
  Future<void> _refreshExpiryIfProvided(
    SessionEntry session,
    Map<String, dynamic> data,
  ) async {
    final envelopeData = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    final expiresAtStr = envelopeData['expiresAt'] as String?;
    if (expiresAtStr == null) return;
    final refreshed = DateTime.tryParse(expiresAtStr);
    if (refreshed == null ||
        !refreshed.isAfter(DateTime.now()) ||
        refreshed == session.expiresAt) {
      return;
    }
    try {
      await (_db.update(
        _db.sessions,
      )..where((t) => t.id.equals(session.id))).write(
        SessionsCompanion(expiresAt: Value(refreshed)),
      );
      logger.i('Session expiry refreshed to $refreshed.');
    } catch (e) {
      // Non-fatal: the session stays valid until its stored expiry.
      logger.w('Could not persist refreshed session expiry: $e');
    }
  }

  /// Clears the current session, purges the offline queue (which carries
  /// the old `deviceId` baked into each `commandJson`), and stands down the
  /// WebSocket so the desktop won't keep seeing a phantom connection.
  /// Also deletes the token from secure storage and forgets the pinned
  /// certificate for this server, so a later re-pair starts clean.
  Future<void> unpair() async {
    final session = await _db.select(_db.sessions).getSingleOrNull();
    await _webSocket.disconnect();
    await _db.delete(_db.queueItems).go();
    await _db.delete(_db.sessions).go();
    await _deleteTokenBestEffort();
    if (session != null) {
      await _forgetPinFor(session.serverUrl);
    }
    _apiClient.clearAuth();
  }
}

/// Thrown when secure storage cannot be read or written at all, as
/// opposed to the token simply being absent. Callers must not treat
/// this as "no session": the token may still be there on the next
/// attempt, so the session row must be kept, not purged.
class _TokenReadFailed implements Exception {
  const _TokenReadFailed();
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
