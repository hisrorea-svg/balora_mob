import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Trust-on-first-use (TOFU) pinning for Balora Desktop's self-signed
/// LAN certificate.
///
/// The desktop generates its own TLS certificate
/// (`tools/setup-mobile-tls.ps1` in the Balora repo), so the platform
/// trust store cannot validate it — which is why the app used to accept
/// *any* certificate (`badCertificateCallback => true`). That let any
/// device on the LAN impersonate the desktop and steal the session
/// token.
///
/// Instead, the first certificate seen for a given `host:port` — during
/// pairing, when the user physically scanned the desktop's QR code — is
/// pinned, and only that exact certificate (compared by its full DER
/// bytes) is accepted afterwards. A different certificate for the same
/// host is rejected, so a later man-in-the-middle cannot take over an
/// already-paired link.
///
/// Consequences, by design:
/// - If the desktop regenerates its certificate, the stored pin no
///   longer matches and connections fail. The user must unpair and
///   re-pair, which re-pins the new certificate.
/// - Trust-on-first-use still trusts the certificate presented at
///   pairing time. Pairing happens in person on the local network,
///   which is the trust anchor here; there is no public CA for a LAN
///   server to pin against instead.
///
/// Pins are stored in secure storage so they survive app restarts.
/// [load] must be awaited before any network call (see `bootstrap`);
/// until then [accepts] fails closed and rejects self-signed
/// certificates. Certificates that pass normal platform validation
/// never reach this callback at all.
class ServerCertificatePins {
  ServerCertificatePins({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Process-wide instance used by the Dio `HttpClient` callback.
  static final ServerCertificatePins instance = ServerCertificatePins();

  static const _keyPrefix = 'balora_tls_pin_';

  final FlutterSecureStorage _storage;

  /// Pinned certificate per `host:port`, as base64 DER bytes.
  final Map<String, String> _pins = {};

  bool _loaded = false;

  /// Whether pins have been loaded from secure storage.
  bool get isLoaded => _loaded;

  /// Loads persisted pins. Safe to call more than once.
  Future<void> load() async {
    if (_loaded) return;
    final all = await _storage.readAll();
    for (final entry in all.entries) {
      if (entry.key.startsWith(_keyPrefix)) {
        _pins[entry.key.substring(_keyPrefix.length)] = entry.value;
      }
    }
    // Set only on success: if storage is unreadable, [_loaded] stays
    // false and [accepts] fails closed, rejecting every self-signed
    // certificate instead of trusting-on-first-use against an empty
    // pin set.
    _loaded = true;
  }

  /// Returns `true` when [cert] may be trusted for [host]:[port].
  ///
  /// The first certificate seen for a host is pinned and accepted.
  /// Afterwards only a byte-identical certificate is accepted.
  bool accepts(String host, int port, X509Certificate cert) {
    if (!_loaded) return false;
    final key = _keyFor(host, port);
    final der = base64Encode(cert.der);
    final pinned = _pins[key];
    if (pinned != null) return pinned == der;
    _pins[key] = der;
    unawaited(
      _storage.write(key: '$_keyPrefix$key', value: der),
    );
    return true;
  }

  /// Forgets the pin for one server, so the next connection re-pins
  /// whatever certificate that server presents. Used when pairing
  /// (or re-pairing) to a server, whose certificate may have been
  /// regenerated since the last pairing.
  Future<void> forget(String host, int port) async {
    final key = _keyFor(host, port);
    _pins.remove(key);
    await _storage.delete(key: '$_keyPrefix$key');
  }

  /// Forgets every stored pin.
  Future<void> clear() async {
    final keys = _pins.keys.toList();
    _pins.clear();
    for (final key in keys) {
      await _storage.delete(key: '$_keyPrefix$key');
    }
  }

  static String _keyFor(String host, int port) => '$host:$port';
}
