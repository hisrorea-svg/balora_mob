import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage for the session token, kept out of the Drift database.
///
/// The token used to be stored as plain text in the `Sessions` table
/// (SQLite file on disk). It now lives only in the platform secure
/// storage (Android Keystore-backed EncryptedSharedPreferences /
/// iOS Keychain), which is the right place for a secret of this kind.
///
/// The [SessionTokenStore] abstraction exists so [AuthRepository] can be
/// tested without a platform channel: tests pass their own in-memory
/// implementation instead of [SecureSessionTokenStore].
abstract class SessionTokenStore {
  Future<String?> readToken();

  Future<void> writeToken(String token);

  Future<void> deleteToken();
}

/// Production [SessionTokenStore] backed by `flutter_secure_storage`.
class SecureSessionTokenStore implements SessionTokenStore {
  SecureSessionTokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              encryptedSharedPreferences: true,
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  static const _tokenKey = 'balora_session_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
