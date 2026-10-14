import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_form_state.freezed.dart';

@freezed
class InventoryFormState with _$InventoryFormState {
  const factory InventoryFormState.idle() = _Idle;
  const factory InventoryFormState.saving() = _Saving;
  const factory InventoryFormState.success() = _Success;
  const factory InventoryFormState.error(String message) = _Error;
}
