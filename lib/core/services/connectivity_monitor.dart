import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../app/bootstrap.dart';

/// Monitors network connectivity changes.
///
/// Provides a reactive stream of connectivity status
/// and triggers sync when connection is restored.
class ConnectivityMonitor {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _controller = StreamController<bool>.broadcast();

  bool _isConnected = true;

  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Whether the device currently has network access.
  bool get isConnected => _isConnected;

  /// Stream that emits `true` when connected, `false` when disconnected.
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Starts listening for connectivity changes.
  Future<void> start() async {
    // Check initial status.
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes.
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    logger.i('📡 Connectivity monitor started (connected: $_isConnected)');
  }

  /// Stops listening for connectivity changes.
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.any((r) => r != ConnectivityResult.none);

    if (_isConnected != wasConnected) {
      logger.i(
        '📡 Connectivity changed: ${_isConnected ? "CONNECTED" : "DISCONNECTED"}',
      );
      _controller.add(_isConnected);
    }
  }
}
