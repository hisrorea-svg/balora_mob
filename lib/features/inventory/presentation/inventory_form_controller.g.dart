// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryFormController)
final inventoryFormControllerProvider = InventoryFormControllerProvider._();

final class InventoryFormControllerProvider
    extends $NotifierProvider<InventoryFormController, InventoryFormState> {
  InventoryFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryFormControllerHash();

  @$internal
  @override
  InventoryFormController create() => InventoryFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryFormState>(value),
    );
  }
}

String _$inventoryFormControllerHash() =>
    r'3627a22dfe178d032cd95f804f97798e80a2932e';

abstract class _$InventoryFormController extends $Notifier<InventoryFormState> {
  InventoryFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InventoryFormState, InventoryFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InventoryFormState, InventoryFormState>,
              InventoryFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
