import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft_entry_state.freezed.dart';

@freezed
class DraftEntryState with _$DraftEntryState {
  const factory DraftEntryState.idle() = _Idle;
  const factory DraftEntryState.saving() = _Saving;
  const factory DraftEntryState.success({required String draftId}) = _Success;
  const factory DraftEntryState.error(String message) = _Error;
}
