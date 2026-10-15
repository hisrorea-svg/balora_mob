import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/models/command.dart';
import '../../../core/providers.dart';
import '../../../core/result/result.dart';
import '../../../core/sync/database/tables.dart' show QueuePriority;
import '../../auth/domain/auth_repository.dart';
import '../data/count_api.dart';
import '../domain/count_models.dart';
import 'count_session_state.dart';
import 'counts_providers.dart';

part 'count_session_controller.g.dart';

const _uuid = Uuid();

/// Owns one counting session: loads the server snapshot, sends scan/quantity
/// commands directly for an immediate verdict, and falls back to the offline
/// queue (same commandId) when the LAN server cannot be reached.
@riverpod
class CountSession extends _$CountSession {
  late final String _countId;
  Timer? _feedbackTimer;
  bool _busy = false;

  @override
  CountSessionState build(String countId) {
    _countId = countId;
    ref.onDispose(() => _feedbackTimer?.cancel());
    return const CountSessionState(loading: true);
  }

  /// Loads (or reloads) the count header, KPI totals and the line page.
  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final snapshot = await ref
          .read(countApiProvider)
          .getCountSummary(_countId);
      state = state.copyWith(
        loading: false,
        snapshot: snapshot,
        clearError: true,
      );
    } on Exception catch (error) {
      state = state.copyWith(loading: false, error: getErrorMessage(error));
    }
  }

  /// Sends one scan for [barcode]; on success updates the line locally, on an
  /// ambiguous product surfaces the batch picker, and on a network failure
  /// queues the identical command for a later retry.
  Future<void> submitScan(String rawBarcode, {String? batchId}) async {
    final barcode = rawBarcode.trim();
    if (barcode.isEmpty || _busy) return;
    _busy = true;
    state = state.copyWith(busy: true, clearBatchSelection: true);
    final commandId = _uuid.v4();
    try {
      final result = await ref
          .read(countApiProvider)
          .scan(
            commandId: commandId,
            countId: _countId,
            barcode: barcode,
            batchId: batchId,
          );
      if (result.isSuccess) {
        _applyLineResult(result);
        _setFeedback(_scanFeedback(result), isError: false);
      } else if (result.code == 'count_batch_selection_required') {
        state = state.copyWith(
          batchSelection: BatchSelectionRequest(
            barcode: barcode,
            productName: result.productName ?? 'مادة',
            options: result.batchOptions,
          ),
        );
      } else {
        _setFeedback(result.message ?? 'تعذر تسجيل المسحة.', isError: true);
      }
    } on Exception catch (error) {
      await _handleSendFailure(
        error,
        type: CommandType.countScan,
        commandId: commandId,
        barcode: barcode,
        payload: {'countId': _countId, 'batchId': ?batchId},
      );
    } finally {
      _busy = false;
      state = state.copyWith(busy: false);
    }
  }

  /// Sets the absolute counted quantity of one line as packages + loose units.
  Future<void> submitSet({
    required String lineId,
    required int packages,
    required int looseUnits,
  }) async {
    if (_busy || packages < 0 || looseUnits < 0) return;
    _busy = true;
    state = state.copyWith(busy: true);
    final commandId = _uuid.v4();
    try {
      final result = await ref
          .read(countApiProvider)
          .setQuantity(
            commandId: commandId,
            countId: _countId,
            lineId: lineId,
            packages: packages,
            looseUnits: looseUnits,
          );
      if (result.isSuccess) {
        _applyLineResult(result);
        _setFeedback(_setFeedbackMessage(result), isError: false);
      } else {
        _setFeedback(result.message ?? 'تعذر تعديل الكمية.', isError: true);
      }
    } on Exception catch (error) {
      await _handleSendFailure(
        error,
        type: CommandType.countSet,
        commandId: commandId,
        payload: {
          'countId': _countId,
          'lineId': lineId,
          'packages': packages,
          'looseUnits': looseUnits,
        },
      );
    } finally {
      _busy = false;
      state = state.copyWith(busy: false);
    }
  }

  /// Resends the pending scan with the chosen batch.
  void resolveBatchSelection(CountBatchOption option) {
    final pending = state.batchSelection;
    if (pending == null) return;
    state = state.copyWith(clearBatchSelection: true);
    unawaited(submitScan(pending.barcode, batchId: option.batchId));
  }

  void dismissBatchSelection() {
    state = state.copyWith(clearBatchSelection: true);
  }

  void clearFeedback() {
    _feedbackTimer?.cancel();
    state = state.copyWith(clearFeedback: true);
  }

  Future<void> _handleSendFailure(
    Object error, {
    required CommandType type,
    required String commandId,
    String? barcode,
    required Map<String, dynamic> payload,
  }) async {
    if (error is UnauthorizedException) {
      await ref.read(authRepositoryProvider).unpair();
      ref.read(authStateProvider.notifier).set(false);
      return;
    }
    if (isCountRetryableOffline(error)) {
      await _queueOffline(
        type: type,
        commandId: commandId,
        barcode: barcode,
        payload: payload,
      );
      return;
    }
    _setFeedback(getErrorMessage(error), isError: true);
  }

  Future<void> _queueOffline({
    required CommandType type,
    required String commandId,
    String? barcode,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final deviceId = await ref.read(authRepositoryProvider).getDeviceId();
      await ref
          .read(queueServiceProvider)
          .enqueueCommand(
            type: type,
            deviceId: deviceId ?? 'unknown-device',
            barcode: barcode,
            commandId: commandId,
            payload: payload,
            priority: QueuePriority.high,
          );
      _setFeedback(
        'لا يوجد اتصال بالكمبيوتر — حُفظت العملية وستُرسل تلقائياً.',
        isError: false,
      );
    } on Exception {
      _setFeedback('تعذر حفظ العملية على الهاتف.', isError: true);
    }
  }

  void _applyLineResult(CountCommandResult result) {
    final snapshot = state.snapshot;
    final line = _lineFromResult(result);
    if (snapshot == null || line == null) return;
    final lines = [...snapshot.lines];
    final index = lines.indexWhere((item) => item.lineId == line.lineId);
    if (index >= 0) {
      lines[index] = line;
    } else {
      lines.add(line);
    }
    state = state.copyWith(snapshot: snapshot.withLines(lines));
  }

  CountLine? _lineFromResult(CountCommandResult result) {
    final lineId = result.lineId;
    if (lineId == null) return null;
    return CountLine(
      lineId: lineId,
      productId: result.productId ?? '',
      productName: result.productName ?? '',
      batchId: result.batchId,
      batchNumber: result.batchNumber,
      expiryDate: result.expiryDate,
      unitsPerPackage: result.unitsPerPackage,
      expectedQuantity: result.expectedQuantity,
      countedQuantity: result.countedQuantity,
      difference: result.difference,
    );
  }

  String _scanFeedback(CountCommandResult result) {
    final counted = result.countedQuantity ?? 0;
    return 'سُجّل: ${result.productName ?? 'مادة'} — المعدود $counted';
  }

  String _setFeedbackMessage(CountCommandResult result) {
    final counted = result.countedQuantity ?? 0;
    return 'حُدّث المعدود إلى $counted — ${_varianceWord(result.difference)}';
  }

  String _varianceWord(int? difference) {
    if (difference == null) return 'لم يُجرد';
    if (difference == 0) return 'مطابق';
    return difference < 0 ? 'عجز ${-difference}' : 'زيادة $difference';
  }

  void _setFeedback(String message, {required bool isError}) {
    _feedbackTimer?.cancel();
    state = state.copyWith(feedback: message, feedbackIsError: isError);
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      state = state.copyWith(clearFeedback: true);
    });
  }
}
