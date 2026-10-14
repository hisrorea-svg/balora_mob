import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';

/// The current state of the sync engine.
@freezed
sealed class SyncStatus with _$SyncStatus {
  /// Engine is idle — no pending items.
  const factory SyncStatus.idle() = SyncIdle;

  /// Engine is actively syncing.
  const factory SyncStatus.syncing({required int pending, required int total}) =
      SyncSyncing;

  /// Engine encountered an error.
  const factory SyncStatus.error({required String message}) = SyncError;

  /// Engine is paused because device is offline.
  const factory SyncStatus.offline() = SyncOffline;
}
