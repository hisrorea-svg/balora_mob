import '../../../app/bootstrap.dart';
import 'link_preferences.dart';

/// A Balora Desktop server the mobile app can link with using a
/// 6-digit code.
class DesktopServer {
  const DesktopServer({
    required this.url,
    this.label,
    this.isLastUsed = false,
    this.isDiscovered = false,
  });

  /// Base URL, e.g. `https://192.168.1.15:4784`.
  final String url;

  /// Human-readable name, if known.
  final String? label;

  /// True when this is the server the user linked with last.
  final bool isLastUsed;

  /// True when this server was actively discovered on the LAN via mDNS.
  final bool isDiscovered;

  DesktopServer copyWith({
    String? url,
    String? label,
    bool? isLastUsed,
    bool? isDiscovered,
  }) {
    return DesktopServer(
      url: url ?? this.url,
      label: label ?? this.label,
      isLastUsed: isLastUsed ?? this.isLastUsed,
      isDiscovered: isDiscovered ?? this.isDiscovered,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DesktopServer &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          label == other.label &&
          isLastUsed == other.isLastUsed &&
          isDiscovered == other.isDiscovered;

  @override
  int get hashCode => Object.hash(url, label, isLastUsed, isDiscovered);
}

/// Normalizes a server URL so manual entries and mDNS discoveries for the same
/// host/port deduplicate reliably.
String normalizeDesktopServerUrlKey(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final lower = trimmed.toLowerCase();
  final candidate =
      (lower.startsWith('http://') || lower.startsWith('https://'))
      ? trimmed
      : 'https://$trimmed';
  final uri = Uri.tryParse(candidate);
  if (uri == null || uri.host.isEmpty) {
    return lower.replaceFirst(RegExp(r'/+$'), '');
  }
  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase();
  final port = uri.hasPort ? ':${uri.port}' : '';
  return '$scheme://$host$port';
}

/// Source of desktop servers for the 6-digit-code link flow.
///
/// A typed code carries no server address (unlike the QR code, which
/// embeds the URL), so the link screen needs somewhere to get the
/// address from. Implementations include [ManualDesktopServerSource]
/// and LAN mDNS discovery (`MdnsDesktopServerSource`).
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

/// Combines multiple [DesktopServerSource] instances concurrently, isolating
/// failures per source, deduplicating by normalized URL, and ordering results
/// with [DesktopServer.isLastUsed] first, then [DesktopServer.isDiscovered].
class CompositeDesktopServerSource implements DesktopServerSource {
  CompositeDesktopServerSource(this.sources);

  final List<DesktopServerSource> sources;

  @override
  Future<List<DesktopServer>> discover() async {
    if (sources.isEmpty) return const [];

    final batches = await Future.wait(
      sources.map((source) async {
        try {
          return await source.discover();
        } catch (e) {
          logger.w('Desktop server source ${source.runtimeType} failed: $e');
          return const <DesktopServer>[];
        }
      }),
    );

    final mergedByKey = <String, DesktopServer>{};
    for (final batch in batches) {
      for (final server in batch) {
        final key = normalizeDesktopServerUrlKey(server.url);
        if (key.isEmpty) continue;

        final existing = mergedByKey[key];
        if (existing == null) {
          mergedByKey[key] = server;
        } else {
          final existingLabel = existing.label?.trim();
          final incomingLabel = server.label?.trim();
          final mergedLabel =
              (server.isDiscovered &&
                  incomingLabel != null &&
                  incomingLabel.isNotEmpty)
              ? incomingLabel
              : (existingLabel != null && existingLabel.isNotEmpty)
              ? existingLabel
              : (incomingLabel != null && incomingLabel.isNotEmpty)
              ? incomingLabel
              : null;

          mergedByKey[key] = DesktopServer(
            url: existing.url,
            label: mergedLabel,
            isLastUsed: existing.isLastUsed || server.isLastUsed,
            isDiscovered: existing.isDiscovered || server.isDiscovered,
          );
        }
      }
    }

    final lastUsed = <DesktopServer>[];
    final discovered = <DesktopServer>[];
    final others = <DesktopServer>[];

    for (final server in mergedByKey.values) {
      if (server.isLastUsed) {
        lastUsed.add(server);
      } else if (server.isDiscovered) {
        discovered.add(server);
      } else {
        others.add(server);
      }
    }

    return [...lastUsed, ...discovered, ...others];
  }
}
