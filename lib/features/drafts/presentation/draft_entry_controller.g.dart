// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_entry_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DraftEntryController)
final draftEntryControllerProvider = DraftEntryControllerProvider._();

final class DraftEntryControllerProvider
    extends $NotifierProvider<DraftEntryController, DraftEntryState> {
  DraftEntryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftEntryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftEntryControllerHash();

  @$internal
  @override
  DraftEntryController create() => DraftEntryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DraftEntryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DraftEntryState>(value),
    );
  }
}

String _$draftEntryControllerHash() =>
    r'a46017d0ca845870b84cd687ab15b04aad649165';

abstract class _$DraftEntryController extends $Notifier<DraftEntryState> {
  DraftEntryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DraftEntryState, DraftEntryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DraftEntryState, DraftEntryState>,
              DraftEntryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
