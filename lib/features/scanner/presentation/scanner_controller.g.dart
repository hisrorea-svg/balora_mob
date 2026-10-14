// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScannerController)
final scannerControllerProvider = ScannerControllerProvider._();

final class ScannerControllerProvider
    extends $NotifierProvider<ScannerController, ScannerState> {
  ScannerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scannerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scannerControllerHash();

  @$internal
  @override
  ScannerController create() => ScannerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScannerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScannerState>(value),
    );
  }
}

String _$scannerControllerHash() => r'4b407427977b39cf17fc50b0cec9dd24559e6e33';

abstract class _$ScannerController extends $Notifier<ScannerState> {
  ScannerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScannerState, ScannerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScannerState, ScannerState>,
              ScannerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
