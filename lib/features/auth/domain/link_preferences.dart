import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'link_preferences.g.dart';

/// Persists non-secret linking preferences — the last desktop server
/// the user linked with — so the 6-digit-code flow can offer it without
/// typing the address again.
///
/// The session token itself is never stored here: it lives in secure
/// storage (see `SessionTokenStore`).
class LinkPreferences {
  LinkPreferences(this._prefs);

  static const _lastServerUrlKey = 'balora_last_server_url';

  final SharedPreferences _prefs;

  /// The last server URL a pairing succeeded with, if any.
  String? get lastServerUrl => _prefs.getString(_lastServerUrlKey);

  Future<void> rememberServerUrl(String url) =>
      _prefs.setString(_lastServerUrlKey, url);

  Future<void> forgetServerUrl() => _prefs.remove(_lastServerUrlKey);
}

@Riverpod(keepAlive: true)
Future<LinkPreferences> linkPreferences(Ref ref) async {
  return LinkPreferences(await SharedPreferences.getInstance());
}
