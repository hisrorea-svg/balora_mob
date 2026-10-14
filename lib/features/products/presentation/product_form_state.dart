import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_form_state.freezed.dart';

@freezed
class ProductFormState with _$ProductFormState {
  const factory ProductFormState.idle() = _Idle;
  const factory ProductFormState.saving() = _Saving;
  const factory ProductFormState.success() = _Success;
  const factory ProductFormState.error(String message) = _Error;
}
