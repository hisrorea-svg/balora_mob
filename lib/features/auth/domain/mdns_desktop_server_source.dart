import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart';

import '../../../app/bootstrap.dart';
import 'desktop_server_source.dart';

/// DNS-SD service type advertised by Balora Desktop (`mobile_mdns.rs`).
const String baloraMdnsServiceType = '_balora._tcp';

/// Signature for injecting a custom record fetcher in tests.
typedef MdnsRecordDiscoverer =
    Future<List<MdnsServiceRecord>> Function(
      String serviceType,
      Duration timeout,
    );

/// Normalized representation of a discovered mDNS service record.
class MdnsServiceRecord {
  const MdnsServiceRecord({
    this.name,
    this.host,
    this.port,
    this.addresses = const [],
    this.txt = const {},
  });

  final String? name;
  final String? host;
  final int? port;
  final List<InternetAddress> addresses;
  final Map<String, String> txt;
}

/// Maps a resolved [MdnsServiceRecord] from `_balora._tcp` to a
/// [DesktopServer], returning `null` if no usable host or port exists.
DesktopServer? desktopServerFromMdnsRecord(MdnsServiceRecord record) {
  final rawScheme = _txtLookup(record.txt, 'scheme')?.toLowerCase();
  final scheme = (rawScheme == 'http' || rawScheme == 'https')
      ? rawScheme!
      : 'https';

  final txtPort = int.tryParse(_txtLookup(record.txt, 'port') ?? '');
  final port = (txtPort != null && txtPort > 0 && txtPort <= 65535)
      ? txtPort
      : (record.port != null && record.port! > 0 && record.port! <= 65535)
      ? record.port
      : null;
  if (port == null) return null;

  final host = _selectHost(record.addresses, record.host);
  if (host == null) return null;

  final formattedHost = host.contains(':') ? '[$host]' : host;
  final txtName = _txtLookup(record.txt, 'name');
  final serviceName = record.name?.trim();
  final label = (txtName != null && txtName.isNotEmpty)
      ? txtName
      : (serviceName != null && serviceName.isNotEmpty)
      ? serviceName
      : null;

  return DesktopServer(
    url: '$scheme://$formattedHost:$port',
    label: label,
    isDiscovered: true,
  );
}

String? _txtLookup(Map<String, String> txt, String key) {
  final direct = txt[key]?.trim();
  if (direct != null) return direct;
  final lowerKey = key.toLowerCase();
  for (final entry in txt.entries) {
    if (entry.key.toLowerCase() == lowerKey) {
      return entry.value.trim();
    }
  }
  return null;
}

String? _selectHost(List<InternetAddress> addresses, String? fallbackHost) {
  final ipv4s = addresses
      .where((addr) => addr.type == InternetAddressType.IPv4)
      .toList(growable: false);

  // 1. Prefer a non-loopback, non-link-local, non-unspecified IPv4 address.
  for (final addr in ipv4s) {
    final ip = addr.address.trim();
    if (!_isLoopbackIpv4(addr) &&
        !_isLinkLocalIpv4(addr) &&
        ip != '0.0.0.0' &&
        ip.isNotEmpty) {
      return ip;
    }
  }

  // 2. Fallback to any other non-loopback IPv4 address.
  for (final addr in ipv4s) {
    final ip = addr.address.trim();
    if (!_isLoopbackIpv4(addr) && ip != '0.0.0.0' && ip.isNotEmpty) {
      return ip;
    }
  }

  // 3. Fallback to cleaned mDNS host name (strip trailing DNS root dots).
  final cleanedHost = fallbackHost
      ?.trim()
      .replaceAll(RegExp(r'\.+$'), '')
      .trim();
  if (cleanedHost != null && cleanedHost.isNotEmpty) {
    return cleanedHost;
  }

  return null;
}

bool _isLoopbackIpv4(InternetAddress addr) =>
    addr.isLoopback || addr.address.startsWith('127.');

bool _isLinkLocalIpv4(InternetAddress addr) =>
    addr.isLinkLocal || addr.address.startsWith('169.254.');

/// Discovers Balora Desktop instances advertising `_balora._tcp` on the LAN.
///
/// Fails softly if multicast is unavailable, denied, or throws on the current
/// platform — manual/remembered server entry always keeps working.
class MdnsDesktopServerSource implements DesktopServerSource {
  MdnsDesktopServerSource({
    this.serviceType = baloraMdnsServiceType,
    this.timeout = const Duration(milliseconds: 2500),
    this.settleDuration = const Duration(milliseconds: 600),
    this.discoverRecords,
  });

  final String serviceType;
  final Duration timeout;
  final Duration settleDuration;
  final MdnsRecordDiscoverer? discoverRecords;

  @override
  Future<List<DesktopServer>> discover() async {
    try {
      final records = await (discoverRecords != null
          ? discoverRecords!(serviceType, timeout)
          : _nsdDiscoverRecords(serviceType, timeout));

      final byKey = <String, DesktopServer>{};
      for (final record in records) {
        final server = desktopServerFromMdnsRecord(record);
        if (server == null) continue;
        byKey.putIfAbsent(
          normalizeDesktopServerUrlKey(server.url),
          () => server,
        );
      }
      return byKey.values.toList(growable: false);
    } catch (e) {
      logger.w('LAN mDNS discovery unavailable: $e');
      return const [];
    }
  }

  Future<List<MdnsServiceRecord>> _nsdDiscoverRecords(
    String serviceType,
    Duration timeout,
  ) async {
    Discovery? discovery;
    Timer? maxTimer;
    Timer? settleTimer;
    ServiceListener? listener;
    final completer = Completer<void>();

    void finish() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    try {
      discovery = await startDiscovery(
        serviceType,
        ipLookupType: IpLookupType.any,
      );

      final collected = <String, MdnsServiceRecord>{};

      void collectService(Service service) {
        final record = _recordFromNsdService(service);
        final mapped = desktopServerFromMdnsRecord(record);
        if (mapped == null) return;
        collected[normalizeDesktopServerUrlKey(mapped.url)] = record;

        if (settleTimer == null) {
          final effectiveSettle = settleDuration < timeout
              ? settleDuration
              : timeout;
          if (effectiveSettle <= Duration.zero) {
            finish();
          } else {
            settleTimer = Timer(effectiveSettle, finish);
          }
        }
      }

      listener = (Service service, ServiceStatus status) {
        if (status == ServiceStatus.found) {
          collectService(service);
        }
      };

      discovery.addServiceListener(listener);
      for (final existing in discovery.services) {
        collectService(existing);
      }

      if (!completer.isCompleted) {
        if (timeout <= Duration.zero) {
          finish();
        } else {
          maxTimer = Timer(timeout, finish);
          await completer.future;
        }
      }

      return collected.values.toList(growable: false);
    } finally {
      maxTimer?.cancel();
      settleTimer?.cancel();
      if (discovery != null) {
        if (listener != null) {
          discovery.removeServiceListener(listener);
        }
        try {
          await stopDiscovery(discovery);
        } catch (e) {
          logger.w('Failed to stop mDNS discovery cleanly: $e');
        }
      }
    }
  }

  static MdnsServiceRecord _recordFromNsdService(Service service) {
    final txt = <String, String>{};
    final rawTxt = service.txt;
    if (rawTxt != null) {
      for (final entry in rawTxt.entries) {
        final Uint8List? bytes = entry.value;
        if (bytes == null) continue;
        txt[entry.key] = utf8.decode(bytes, allowMalformed: true).trim();
      }
    }
    return MdnsServiceRecord(
      name: service.name,
      host: service.host,
      port: service.port,
      addresses: service.addresses ?? const [],
      txt: txt,
    );
  }
}

/// Provides the LAN mDNS discovery source for [AuthController.loadServers].
final mdnsDesktopServerSourceProvider = Provider<DesktopServerSource>(
  (ref) => MdnsDesktopServerSource(),
);
