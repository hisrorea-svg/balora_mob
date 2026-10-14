import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/sync/database/app_database.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isLoading,
    SessionEntry? session,
    @Default(0) int pendingQueueCount,
    @Default(false) bool isConnected,
  }) = _SettingsState;
}
