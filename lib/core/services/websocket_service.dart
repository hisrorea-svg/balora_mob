import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../app/bootstrap.dart';
import '../api/models/ack_response.dart';

/// Manages the WebSocket connection to Balora Desktop.
///
/// Handles:
/// - Connection lifecycle (connect, disconnect, auto-reconnect)
/// - Authenticated handshake (session token correlation)
/// - Incoming ACK messages
/// - Connection state notifications (verified link only)
class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _pongWaitTimer;

  String? _serverUrl;
  String? _sessionToken;
  String? _deviceId;

  /// Whether the link should auto-reconnect on drop.
  bool _shouldReconnect = false;

  /// Latched only AFTER the desktop confirms the link is authenticated.
  bool _isConnected = false;

  /// True while the TCP socket is open but the auth handshake is in flight.
  bool _isAuthenticating = false;

  int _reconnectAttempts = 0;
  bool _awaitingPong = false;

  /// Pong must arrive within this window after a ping, otherwise the socket
  /// is considered half-open and we force a reconnect.
  static const _pongTimeout = Duration(seconds: 10);
  static const _pingInterval = Duration(seconds: 30);
  static const _authTimeout = Duration(seconds: 5);

  /// Maximum delay between reconnect attempts (exponential backoff cap).
  static const _maxReconnectDelay = Duration(seconds: 60);

  final _ackController = StreamController<AckResponse>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  /// Stream of ACK responses from the server.
  Stream<AckResponse> get onAck => _ackController.stream;

  /// Stream of connection state changes (only emits `true` once the desktop
  /// has confirmed the authenticated link, never merely on TCP open).
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  /// Whether the WebSocket/HTTP session link is *verified* as connected & authenticated.
  bool get isConnected => _isConnected;

  /// Updates the verified connection state from the HTTP session handshake
  /// (`/m/api/pair` or `/m/api/session`) when the desktop uses the REST-only
  /// mobile listener.
  void setSessionConnected(bool value) {
    if (!value) {
      _isAuthenticating = false;
    }
    _setConnected(value);
  }

  /// Builds the authenticated WebSocket URL from a base server URL.
  static String buildWsUrl(
    String serverUrl, {
    required String sessionToken,
    String? deviceId,
  }) {
    var url = serverUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
      url = 'ws://$url';
    }
    if (!url.endsWith('/ws')) {
      url = '$url/ws';
    }
    final sep = url.contains('?') ? '&' : '?';
    final params =
        'token=${Uri.encodeComponent(sessionToken)}'
        '${deviceId == null ? '' : '&deviceId=${Uri.encodeComponent(deviceId)}'}';
    return '$url$sep$params';
  }

  /// Connects to the Balora Desktop WebSocket endpoint with the persisted
  /// session token so the desktop can correlate this WS to a paired device.
  ///
  /// Pass the same [sessionToken] returned by the pairing endpoint. The
  /// desktop uses it to populate its "linked mobile devices" list.
  Future<void> connect(
    String serverUrl, {
    required String sessionToken,
    String? deviceId,
  }) async {
    _serverUrl = serverUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    if (!_serverUrl!.startsWith('ws://') && !_serverUrl!.startsWith('wss://')) {
      _serverUrl = 'ws://$_serverUrl';
    }
    if (!_serverUrl!.endsWith('/ws')) {
      _serverUrl = '$_serverUrl/ws';
    }
    _sessionToken = sessionToken;
    _deviceId = deviceId;

    _shouldReconnect = true;
    _reconnectAttempts = 0;
    await _doConnect();
  }

  /// Re-arms the reconnect flag and immediately attempts to reconnect.
  ///
  /// Used by the app-lifecycle observer (on resume) and by the
  /// connectivity monitor (on network restored). Safe to call when the
  /// link is already up or a reconnect is already scheduled.
  Future<void> rearmAndReconnect() async {
    _shouldReconnect = true;
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    if (!_isConnected && !_isAuthenticating) {
      await _doConnect();
    }
  }

  /// Disconnects from the WebSocket server.
  ///
  /// [keepReconnectArmed] controls whether the monitor should keep trying.
  /// - `unpair()` passes `false` to fully stand-down.
  /// - everything else uses the default `false` and calls [rearmAndReconnect]
  ///   when needed.
  Future<void> disconnect({bool keepReconnectArmed = false}) async {
    _shouldReconnect = keepReconnectArmed;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _pongWaitTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _isAuthenticating = false;
    _setConnected(false);
    logger.i('🔌 WebSocket disconnected');
  }

  /// Sends a JSON message over the WebSocket.
  void send(Map<String, dynamic> message) {
    if (_channel == null) {
      logger.w('⚠️ Cannot send WS message — not connected');
      return;
    }
    _channel!.sink.add(jsonEncode(message));
  }

  /// Cleans up all resources. Called by the Riverpod provider when disposed.
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _pongWaitTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _ackController.close();
    _connectionController.close();
  }

  Future<void> _doConnect() async {
    if (_serverUrl == null || _sessionToken == null) {
      logger.w('⚠️ Cannot WS-connect without serverUrl+sessionToken');
      return;
    }

    try {
      logger.i('🔌 Connecting to WebSocket: $_serverUrl');

      final uri = Uri.parse(_serverUrl!);
      // Token is sent both in the query string (so the desktop can identify
      // the WS on connect) and as an `auth` message after open (defence in
      // depth for desktops that clear the query string).
      _channel = WebSocketChannel.connect(
        uri.replace(
          queryParameters: {
            ...uri.queryParameters,
            'token': _sessionToken!,
            'deviceId': ?_deviceId,
          },
        ),
        protocols: const ['balora-v1'],
      );
      await _channel!.ready;
      _reconnectAttempts = 0;
      _isAuthenticating = true;

      // Listen for messages BEFORE sending auth so we don't miss the `ready`.
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      // Send the auth handshake. The desktop is expected to reply with
      // `{"type":"ready"}` once the link is promoted to a paired device.
      send({
        'type': 'auth',
        'token': _sessionToken,
        if (_deviceId != null) 'deviceId': _deviceId,
      });

      // Safety net: if the desktop never replies with `ready`, drop the
      // half-open socket and let reconnect logic kick in.
      Timer(_authTimeout, () {
        if (_isAuthenticating && !_isConnected) {
          logger.w('⚠️ WS auth handshake timed out — dropping socket');
          _channel?.sink.close();
        }
      });
    } on Exception catch (e) {
      logger.e('❌ WebSocket connection failed: $e');
      _channel = null;
      _isAuthenticating = false;
      _setConnected(false);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;

      // Handle link-management frames first.
      final type = data['type'] as String?;
      switch (type) {
        case 'ready':
          // Desktop confirmed the authenticated link.
          _isAuthenticating = false;
          _setConnected(true);
          logger.i('🔌 WebSocket link authenticated (ready)');
          _startPingTimer();
          return;

        case 'pong':
          _awaitingPong = false;
          _pongWaitTimer?.cancel();
          return;

        case 'ping':
          send({'type': 'pong'});
          return;

        case 'connected':
          // Old-style burst from desktop that didn't require auth — treat
          // it as ready too, for backwards compatibility.
          _isAuthenticating = false;
          _setConnected(true);
          _startPingTimer();
          return;
      }

      // Otherwise treat as ACK.
      if (data['commandId'] == null) return;
      final ack = AckResponse.fromJson(data);
      logger.d('📨 ACK received: ${ack.commandId} → ${ack.status}');
      _ackController.add(ack);
    } on FormatException catch (e) {
      logger.w('⚠️ Invalid WS message: $e');
    }
  }

  void _onError(Object error) {
    logger.e('❌ WebSocket error: $error');
    _isAuthenticating = false;
    _setConnected(false);
    _scheduleReconnect();
  }

  void _onDone() {
    logger.w('🔌 WebSocket connection closed');
    _channel = null;
    _pingTimer?.cancel();
    _pongWaitTimer?.cancel();
    _isAuthenticating = false;
    _setConnected(false);
    _scheduleReconnect();
  }

  void _setConnected(bool value) {
    if (_isConnected == value) return;
    _isConnected = value;
    _connectionController.add(value);
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      if (_awaitingPong) {
        // Previous pong never arrived — assume half-open, force reconnect.
        logger.w('⚠️ No pong for previous ping — forcing reconnect');
        _pongWaitTimer?.cancel();
        _channel?.sink.close();
        return;
      }
      _awaitingPong = true;
      send({'type': 'ping'});
      _pongWaitTimer?.cancel();
      _pongWaitTimer = Timer(_pongTimeout, () {
        if (_awaitingPong) {
          logger.w('⚠️ Pong timeout — forcing reconnect');
          _awaitingPong = false;
          _channel?.sink.close();
        }
      });
    });
  }

  void _scheduleReconnect() {
    _pingTimer?.cancel();
    _pongWaitTimer?.cancel();
    if (!_shouldReconnect) return;

    _reconnectAttempts++;
    // Exponential backoff capped at [maxReconnectDelay]; never give up.
    final seconds = (_reconnectAttempts * 2).clamp(
      1,
      _maxReconnectDelay.inSeconds,
    );
    final delay = Duration(seconds: seconds);
    logger.i(
      '🔄 Reconnecting in ${delay.inSeconds}s '
      '(attempt $_reconnectAttempts)',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _doConnect);
  }
}
