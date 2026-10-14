// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the currently active [ScannerMode].
///
/// Defaults to [ScannerMode.search] and is mutated via
/// `ref.read(scannerModeNotifierProvider.notifier).state = ScannerMode.sale`
/// style calls from the home page.
///
/// (Using a `Notifier` keep-around class so the lint rule
/// `avoid_manual_providers_as_generated_provider_dependency` stays satisfied
/// — the previous `StateProvider<Scanner_mode` form made the generated
/// `ScannerController` depend on a manual provider.)

@ProviderFor(ScannerModeNotifier)
final scannerModeProvider = ScannerModeNotifierProvider._();

/// Provides the currently active [ScannerMode].
///
/// Defaults to [ScannerMode.search] and is mutated via
/// `ref.read(scannerModeNotifierProvider.notifier).state = ScannerMode.sale`
/// style calls from the home page.
///
/// (Using a `Notifier` keep-around class so the lint rule
/// `avoid_manual_providers_as_generated_provider_dependency` stays satisfied
/// — the previous `StateProvider<Scanner_mode` form made the generated
/// `ScannerController` depend on a manual provider.)
final class ScannerModeNotifierProvider
    extends $NotifierProvider<ScannerModeNotifier, ScannerMode> {
  /// Provides the currently active [ScannerMode].
  ///
  /// Defaults to [ScannerMode.search] and is mutated via
  /// `ref.read(scannerModeNotifierProvider.notifier).state = ScannerMode.sale`
  /// style calls from the home page.
  ///
  /// (Using a `Notifier` keep-around class so the lint rule
  /// `avoid_manual_providers_as_generated_provider_dependency` stays satisfied
  /// — the previous `StateProvider<Scanner_mode` form made the generated
  /// `ScannerController` depend on a manual provider.)
  ScannerModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scannerModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scannerModeNotifierHash();

  @$internal
  @override
  ScannerModeNotifier create() => ScannerModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScannerMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScannerMode>(value),
    );
  }
}

String _$scannerModeNotifierHash() =>
    r'94853315486373fb4b48289871e47e3db95501f2';

/// Provides the currently active [ScannerMode].
///
/// Defaults to [ScannerMode.search] and is mutated via
/// `ref.read(scannerModeNotifierProvider.notifier).state = ScannerMode.sale`
/// style calls from the home page.
///
/// (Using a `Notifier` keep-around class so the lint rule
/// `avoid_manual_providers_as_generated_provider_dependency` stays satisfied
/// — the previous `StateProvider<Scanner_mode` form made the generated
/// `ScannerController` depend on a manual provider.)

abstract class _$ScannerModeNotifier extends $Notifier<ScannerMode> {
  ScannerMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScannerMode, ScannerMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScannerMode, ScannerMode>,
              ScannerMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
