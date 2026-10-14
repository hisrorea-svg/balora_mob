// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductFormController)
final productFormControllerProvider = ProductFormControllerProvider._();

final class ProductFormControllerProvider
    extends $NotifierProvider<ProductFormController, ProductFormState> {
  ProductFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productFormControllerHash();

  @$internal
  @override
  ProductFormController create() => ProductFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductFormState>(value),
    );
  }
}

String _$productFormControllerHash() =>
    r'3245c9519185193c5691b11da7f3e1eb3010523e';

abstract class _$ProductFormController extends $Notifier<ProductFormState> {
  ProductFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProductFormState, ProductFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductFormState, ProductFormState>,
              ProductFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
