// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(countApi)
final countApiProvider = CountApiProvider._();

final class CountApiProvider
    extends $FunctionalProvider<CountApi, CountApi, CountApi>
    with $Provider<CountApi> {
  CountApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'countApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$countApiHash();

  @$internal
  @override
  $ProviderElement<CountApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CountApi create(Ref ref) {
    return countApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CountApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CountApi>(value),
    );
  }
}

String _$countApiHash() => r'53385fc2208a6f16b41abcb440a24b8e61ab47c5';

/// The open (draft) counts visible to the phone's session site.

@ProviderFor(activeCounts)
final activeCountsProvider = ActiveCountsProvider._();

/// The open (draft) counts visible to the phone's session site.

final class ActiveCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ActiveCount>>,
          List<ActiveCount>,
          FutureOr<List<ActiveCount>>
        >
    with
        $FutureModifier<List<ActiveCount>>,
        $FutureProvider<List<ActiveCount>> {
  /// The open (draft) counts visible to the phone's session site.
  ActiveCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCountsHash();

  @$internal
  @override
  $FutureProviderElement<List<ActiveCount>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ActiveCount>> create(Ref ref) {
    return activeCounts(ref);
  }
}

String _$activeCountsHash() => r'181c9445f80e16ab58175506b1c48498812d3f2c';
