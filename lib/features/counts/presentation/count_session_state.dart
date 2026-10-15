import '../domain/count_models.dart';

/// Batch selection is pending: the last scan hit a product with several active
/// batches and the server asked the operator to choose one.
class BatchSelectionRequest {
  const BatchSelectionRequest({
    required this.barcode,
    required this.productName,
    required this.options,
  });

  final String barcode;
  final String productName;
  final List<CountBatchOption> options;
}

/// State of one open counting session.
class CountSessionState {
  const CountSessionState({
    this.loading = false,
    this.error,
    this.snapshot,
    this.busy = false,
    this.feedback,
    this.feedbackIsError = false,
    this.batchSelection,
    this.offlineQueued = false,
  });

  final bool loading;
  final String? error;
  final CountSnapshot? snapshot;
  final bool busy;
  final String? feedback;
  final bool feedbackIsError;
  final BatchSelectionRequest? batchSelection;

  /// True after a command was stored locally because the server was
  /// unreachable; the banner stays until a later send reaches the server.
  final bool offlineQueued;

  CountSessionState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    CountSnapshot? snapshot,
    bool? busy,
    String? feedback,
    bool clearFeedback = false,
    bool? feedbackIsError,
    BatchSelectionRequest? batchSelection,
    bool clearBatchSelection = false,
    bool? offlineQueued,
  }) {
    return CountSessionState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      snapshot: snapshot ?? this.snapshot,
      busy: busy ?? this.busy,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      batchSelection: clearBatchSelection
          ? null
          : (batchSelection ?? this.batchSelection),
      offlineQueued: offlineQueued ?? this.offlineQueued,
    );
  }
}
