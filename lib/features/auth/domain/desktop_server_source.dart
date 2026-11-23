import 'link_preferences.dart';

/// A Balora Desktop server the mobile app can link with using a
/// 6-digit code.
class DesktopServer {
  const DesktopServer({
    required this.url,
    this.label,
    this.isLastUsed = false,
  });

  /// Base URL, e.g. `https://192.168.1.15:4784`.
  final String url;

  /// Human-readable name, if known.
  final String? label;

  /// True when this is the server the user linked with last.
  final bool isLastUsed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DesktopServer &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          label == other.label &&
          isLastUsed == other.isLastUsed;

  @override
  int get hashCode => Object.hash(url, label, isLastUsed);
}

/// Source of desktop servers for the 6-digit-code link flow.
///
/// A typed code carries no server address (unlike the QR code, which
/// embeds the URL), so the link screen needs somewhere to get the
/// address from. Discovery is the extension point for this:
///
/// - Today only [ManualDesktopServerSource] exists: no discovery, just
///   the remembered last-used server plus manual entry in the UI.
/// - When the desktop starts advertising itself on the LAN (mDNS,
///   plan step D4), add a discovery implementation of this interface
///   and combine its results with the manual source — the UI and the
///   repository do not change. A cloud relay (plan phase 2, online)
///   plugs in the same way.
abstract class DesktopServerSource {
  /// Returns the desktop servers currently available for code linking.
  Future<List<DesktopServer>> discover();
}

/// Manual-only source: returns the last-used server, if one was
/// remembered. No network discovery happens here.
class ManualDesktopServerSource implements DesktopServerSource {
  ManualDesktopServerSource(this._preferences);

  final LinkPreferences _preferences;

  @override
  Future<List<DesktopServer>> discover() async {
    final last = _preferences.lastServerUrl;
    if (last == null || last.isEmpty) return const [];
    return [DesktopServer(url: last, isLastUsed: true)];
  }
}
