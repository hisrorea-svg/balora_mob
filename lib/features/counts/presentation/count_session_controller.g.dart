// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'count_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns one counting session: loads the server snapshot, sends scan/quantity
/// commands directly for an immediate verdict, and falls back to the offline
/// queue (same commandId) when the LAN server cannot be reached.

@ProviderFor(CountSession)
final countSessionProvider = CountSessionFamily._();

/// Owns one counting session: loads the server snapshot, sends scan/quantity
/// commands directly for an immediate verdict, and falls back to the offline
/// queue (same commandId) when the LAN server cannot be reached.
final class CountSessionProvider
    extends $NotifierProvider<CountSession, CountSessionState> {
  /// Owns one counting session: loads the server snapshot, sends scan/quantity
  /// commands directly for an immediate verdict, and falls back to the offline
  /// queue (same commandId) when the LAN server cannot be reached.
  CountSessionProvider._({
    required CountSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'countSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$countSessionHash();

  @override
  String toString() {
    return r'countSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CountSession create() => CountSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CountSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CountSessionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CountSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$countSessionHash() => r'29490d48505c57c7ae6f19282b8922fc24330dfa';

/// Owns one counting session: loads the server snapshot, sends scan/quantity
/// commands directly for an immediate verdict, and falls back to the offline
/// queue (same commandId) when the LAN server cannot be reached.

final class CountSessionFamily extends $Family
    with
        $ClassFamilyOverride<
          CountSession,
          CountSessionState,
          CountSessionState,
          CountSessionState,
          String
        > {
  CountSessionFamily._()
    : super(
        retry: null,
        name: r'countSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Owns one counting session: loads the server snapshot, sends scan/quantity
  /// commands directly for an immediate verdict, and falls back to the offline
  /// queue (same commandId) when the LAN server cannot be reached.

  CountSessionProvider call(String countId) =>
      CountSessionProvider._(argument: countId, from: this);

  @override
  String toString() => r'countSessionProvider';
}

/// Owns one counting session: loads the server snapshot, sends scan/quantity
/// commands directly for an immediate verdict, and falls back to the offline
/// queue (same commandId) when the LAN server cannot be reached.

abstract class _$CountSession extends $Notifier<CountSessionState> {
  late final _$args = ref.$arg as String;
  String get countId => _$args;

  CountSessionState build(String countId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CountSessionState, CountSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CountSessionState, CountSessionState>,
              CountSessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
