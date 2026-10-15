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
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/m/api/counts/active',
    );
    final data = _unwrap(result);
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
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/m/api/counts/$countId/summary',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return CountSnapshot.fromJson(_unwrap(result));
  }

  /// Sends one `count_scan` command; [batchId] selects the batch when the
  /// server refuses an ambiguous scan with `count_batch_selection_required`.
  Future<CountCommandResult> scan({
    required String commandId,
    required String countId,
    required String barcode,
    String? batchId,
  }) {
    return _sendCommand({
      'commandId': commandId,
      'type': 'count_scan',
      'barcode': barcode,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'payload': {
        'countId': countId,
        'batchId': ?batchId,
      },
    });
  }

  /// Sends one `count_set` command that sets the absolute counted quantity of
  /// a line as packages + loose base units (the server owns the conversion).
  Future<CountCommandResult> setQuantity({
    required String commandId,
    required String countId,
    required String lineId,
    required int packages,
    required int looseUnits,
  }) {
    return _sendCommand({
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

  /// Unwraps the `{ok, correlationId, data}` envelope and maps Problem Details
  /// responses to a [CountApiException] carrying the server's Arabic detail.
  Map<String, dynamic> _unwrap(Result<Map<String, dynamic>> result) {
    switch (result) {
      case Success(:final data):
        final inner = data['data'];
        if (inner is Map<String, dynamic>) return inner;
        return data;
      case Failure(:final exception):
        if (exception is ServerException &&
            exception.serverMessage != null &&
            _looksLikeProblem(exception.serverMessage!)) {
          throw CountApiException(
            _problemDetail(exception.serverMessage!) ??
                exception.userMessage,
            code: _problemCode(exception.serverMessage!) ?? 'count_read_failed',
            status: exception.statusCode,
          );
        }
        throw exception;
    }
  }

  bool _looksLikeProblem(String raw) => raw.contains('"code"');

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
