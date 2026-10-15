import '../../../core/api/dio_client.dart';
import '../../../core/result/result.dart';
import '../domain/count_models.dart';

/// Raised when a count read endpoint answers with a Problem Details body.
class CountApiException implements Exception {
  const CountApiException(
    this.message, {
    required this.code,
    required this.status,
  });

  final String message;
  final String code;
  final int status;

  @override
  String toString() => message;
}

/// HTTP access to the mobile stock count surface of the local Balora server.
///
/// Reads: `/m/api/counts/active` and `/m/api/counts/{id}/summary`.
/// Writes: `count_scan` / `count_set` through the shared commands channel.
class CountApi {
  CountApi(this._apiClient);

  final ApiClient _apiClient;

  /// The open drafts for the phone's session site.
  Future<List<ActiveCount>> listActiveCounts() async {
    final data = await _getCountData('/m/api/counts/active');
    final counts = data['counts'];
    if (counts is! List) return const [];
    return counts
        .whereType<Map<String, dynamic>>()
        .map(ActiveCount.fromJson)
        .toList();
  }

  /// One count's header, KPI totals, and line page.
  Future<CountSnapshot> getCountSummary(
    String countId, {
    int limit = 200,
    int offset = 0,
  }) async {
    final data = await _getCountData(
      '/m/api/counts/$countId/summary',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return CountSnapshot.fromJson(data);
  }

  /// Reads one count endpoint as raw JSON. A server that predates the mobile
  /// count surface answers 200 with the PWA HTML fallback (the API paths live
  /// under the `/m/` subtree), so a non-JSON body becomes an explicit Arabic
  /// "update the server" error instead of a generic failure.
  Future<Map<String, dynamic>> _getCountData(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _apiClient.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    switch (result) {
      case Success(:final data):
        if (data is Map<String, dynamic>) return _unwrapData(data);
        if (data is Map) return _unwrapData(data.cast<String, dynamic>());
        throw const CountApiException(
          'خادم Balora لا يدعم قراءات الجرد بعد. حدّث خادم الكمبيوتر ثم أعد المحاولة.',
          code: 'counts_unsupported',
          status: 200,
        );
      case Failure(:final exception):
        throw _mapReadFailure(exception);
    }
  }

  /// Sends one `count_scan` command; [batchId] selects the batch when the
  /// server refuses an ambiguous scan with `count_batch_selection_required`.
  Future<CountCommandResult> scan({
    required String commandId,
    required String countId,
    required String barcode,
    String? batchId,
  }) async {
    final result = await _sendCommand({
      'commandId': commandId,
      'type': 'count_scan',
      'barcode': barcode,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'payload': {'countId': countId, 'batchId': ?batchId},
    });
    _requireCountContract(result);
    return result;
  }

  /// Sends one `count_set` command that sets the absolute counted quantity of
  /// a line as packages + loose base units (the server owns the conversion).
  Future<CountCommandResult> setQuantity({
    required String commandId,
    required String countId,
    required String lineId,
    required int packages,
    required int looseUnits,
  }) async {
    final result = await _sendCommand({
      'commandId': commandId,
      'type': 'count_set',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'payload': {
        'countId': countId,
        'lineId': lineId,
        'packages': packages,
        'looseUnits': looseUnits,
      },
    });
    _requireCountContract(result);
    return result;
  }

  /// A success ACK must carry the updated line; a server that predates MS-3
  /// answers the old canned success without any line data, which would silently
  /// fake a write. Refuse it with an explicit Arabic message instead.
  void _requireCountContract(CountCommandResult result) {
    if (!result.isSuccess) return;
    if (result.lineId != null && result.countedQuantity != null) return;
  throw const CountApiException(
    'خادم Balora لم ينفّذ عملية الجرد (خادم قديم؟). حدّث خادم الكمبيوتر ثم أعد المحاولة.',
    code: 'count_contract_mismatch',
    status: 200,
  );
  }

  Future<CountCommandResult> _sendCommand(Map<String, dynamic> body) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/m/api/commands',
      data: body,
    );
    switch (result) {
      case Success(:final data):
        return CountCommandResult.fromJson(data);
      case Failure(:final exception):
        throw exception;
    }
  }

  /// Unwraps the `{ok, correlationId, data}` envelope of a read response.
  Map<String, dynamic> _unwrapData(Map<String, dynamic> body) {
    final inner = body['data'];
    if (inner is Map<String, dynamic>) return inner;
    if (inner is Map) return inner.cast<String, dynamic>();
    return body;
  }

  /// Maps a failed read to a [CountApiException] carrying the server's Arabic
  /// Problem Details detail, or rethrows the original typed failure.
  Object _mapReadFailure(AppException exception) {
    if (exception is ServerException && exception.serverMessage != null) {
      final raw = exception.serverMessage!;
      final code = _problemCode(raw);
      final detail = _problemDetail(raw);
      if (code != null || detail != null) {
        return CountApiException(
          detail ?? exception.userMessage,
          code: code ?? 'count_read_failed',
          status: exception.statusCode,
        );
      }
    }
    return exception;
  }

  String? _problemCode(String raw) {
    final match = RegExp(r'"code"\s*:\s*"([^"]+)"').firstMatch(raw);
    return match?.group(1);
  }

  String? _problemDetail(String raw) {
    final match = RegExp(r'"detail"\s*:\s*"([^"]+)"').firstMatch(raw);
    return match?.group(1);
  }
}

/// Whether [error] means the LAN server could not be reached or failed
/// transiently, so the command should be queued for a retry instead of being
/// reported as a business refusal. Rate limiting (HTTP 429) is not retryable
/// here: it is a deliberate refusal the operator must see.
bool isCountRetryableOffline(Object error) {
  if (error is NetworkException || error is TimeoutException) return true;
  if (error is ServerException) return error.statusCode >= 500;
  return false;
}
