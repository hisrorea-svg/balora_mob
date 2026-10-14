// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'8c69eb46d45206533c176c88a926608e79ca927d';

/// Synchronous, mutable flag for "is this device currently linked to a
/// desktop". Drives the GoRouter redirect guard.
///
/// Set by:
/// - `SplashScreen` after the WS handshake resolves (true on success, false
///   on failure/no session).
/// - `PairingScreen` after a successful `pairWithQr` (true).
/// - `SettingsController.unpair` when the user explicitly unpairs (false).

@ProviderFor(AuthState)
final authStateProvider = AuthStateProvider._();

/// Synchronous, mutable flag for "is this device currently linked to a
/// desktop". Drives the GoRouter redirect guard.
///
/// Set by:
/// - `SplashScreen` after the WS handshake resolves (true on success, false
///   on failure/no session).
/// - `PairingScreen` after a successful `pairWithQr` (true).
/// - `SettingsController.unpair` when the user explicitly unpairs (false).
final class AuthStateProvider extends $NotifierProvider<AuthState, bool> {
  /// Synchronous, mutable flag for "is this device currently linked to a
  /// desktop". Drives the GoRouter redirect guard.
  ///
  /// Set by:
  /// - `SplashScreen` after the WS handshake resolves (true on success, false
  ///   on failure/no session).
  /// - `PairingScreen` after a successful `pairWithQr` (true).
  /// - `SettingsController.unpair` when the user explicitly unpairs (false).
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  AuthState create() => AuthState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authStateHash() => r'118226456f238d4dd0ee09f60d1b592bebf10c7a';

/// Synchronous, mutable flag for "is this device currently linked to a
/// desktop". Drives the GoRouter redirect guard.
///
/// Set by:
/// - `SplashScreen` after the WS handshake resolves (true on success, false
///   on failure/no session).
/// - `PairingScreen` after a successful `pairWithQr` (true).
/// - `SettingsController.unpair` when the user explicitly unpairs (false).

abstract class _$AuthState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// API Client Provider.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// API Client Provider.

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  /// API Client Provider.
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'a8aa67fef9c5af08a847ab6880488484a2e92e06';

/// Connectivity Provider — `.start()` is invoked eagerly so the underlying
/// network status stream is live from the first frame (audit: previously
/// `.start()` was never called and `_isConnected` stayed `true` forever).

@ProviderFor(connectivityMonitor)
final connectivityMonitorProvider = ConnectivityMonitorProvider._();

/// Connectivity Provider — `.start()` is invoked eagerly so the underlying
/// network status stream is live from the first frame (audit: previously
/// `.start()` was never called and `_isConnected` stayed `true` forever).

final class ConnectivityMonitorProvider
    extends
        $FunctionalProvider<
          ConnectivityMonitor,
          ConnectivityMonitor,
          ConnectivityMonitor
        >
    with $Provider<ConnectivityMonitor> {
  /// Connectivity Provider — `.start()` is invoked eagerly so the underlying
  /// network status stream is live from the first frame (audit: previously
  /// `.start()` was never called and `_isConnected` stayed `true` forever).
  ConnectivityMonitorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityMonitorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityMonitorHash();

  @$internal
  @override
  $ProviderElement<ConnectivityMonitor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectivityMonitor create(Ref ref) {
    return connectivityMonitor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityMonitor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityMonitor>(value),
    );
  }
}

String _$connectivityMonitorHash() =>
    r'065395967c4f27f40c6641ecdd53e4bf091df2b8';

/// The *single* source of the [WebSocketService] instance. Use this provider
/// everywhere — defining it in two different files was previously causing the
/// connection-state stream to subscribe to a *different* instance and miss
/// every connection event.

@ProviderFor(webSocketService)
final webSocketServiceProvider = WebSocketServiceProvider._();

/// The *single* source of the [WebSocketService] instance. Use this provider
/// everywhere — defining it in two different files was previously causing the
/// connection-state stream to subscribe to a *different* instance and miss
/// every connection event.

final class WebSocketServiceProvider
    extends
        $FunctionalProvider<
          WebSocketService,
          WebSocketService,
          WebSocketService
        >
    with $Provider<WebSocketService> {
  /// The *single* source of the [WebSocketService] instance. Use this provider
  /// everywhere — defining it in two different files was previously causing the
  /// connection-state stream to subscribe to a *different* instance and miss
  /// every connection event.
  WebSocketServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webSocketServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webSocketServiceHash();

  @$internal
  @override
  $ProviderElement<WebSocketService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WebSocketService create(Ref ref) {
    return webSocketService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebSocketService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebSocketService>(value),
    );
  }
}

String _$webSocketServiceHash() => r'dcfa03f9dc1cac328bcb3e9081ef183283883921';

@ProviderFor(ConnectionState)
final connectionStateProvider = ConnectionStateProvider._();

final class ConnectionStateProvider
    extends $NotifierProvider<ConnectionState, bool> {
  ConnectionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionStateHash();

  @$internal
  @override
  ConnectionState create() => ConnectionState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$connectionStateHash() => r'4e2bfda1df4e969d1d028586c704f030d8e1800f';

abstract class _$ConnectionState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Queue DAO Provider.

@ProviderFor(queueDao)
final queueDaoProvider = QueueDaoProvider._();

/// Queue DAO Provider.

final class QueueDaoProvider
    extends $FunctionalProvider<QueueDao, QueueDao, QueueDao>
    with $Provider<QueueDao> {
  /// Queue DAO Provider.
  QueueDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueDaoHash();

  @$internal
  @override
  $ProviderElement<QueueDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QueueDao create(Ref ref) {
    return queueDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueueDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueueDao>(value),
    );
  }
}

String _$queueDaoHash() => r'693ca7f15c299bb9e07ad3053cfeb4f51c262406';

/// Queue Service Provider.

@ProviderFor(queueService)
final queueServiceProvider = QueueServiceProvider._();

/// Queue Service Provider.

final class QueueServiceProvider
    extends $FunctionalProvider<QueueService, QueueService, QueueService>
    with $Provider<QueueService> {
  /// Queue Service Provider.
  QueueServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueServiceHash();

  @$internal
  @override
  $ProviderElement<QueueService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QueueService create(Ref ref) {
    return queueService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueueService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueueService>(value),
    );
  }
}

String _$queueServiceHash() => r'8d8dc25320e3a2879d92987d1ba28939c5d2f3a1';
