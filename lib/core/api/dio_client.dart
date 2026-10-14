import 'package:dio/dio.dart';

import '../../app/bootstrap.dart';
import '../result/result.dart';



class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Updates the base URL after QR pairing.
  void setBaseUrl(String baseUrl) {
    baseUrl = baseUrl.trim();
    if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
      baseUrl = 'https://$baseUrl';
    }
    while (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _dio.options.baseUrl = baseUrl;
  }

  /// Sets the session token for authenticated requests.
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clears only the Authorization header without resetting the base URL.
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Clears authentication (logout / unpair).
  void clearAuth() {
    _dio.options.headers.remove('Authorization');
    _dio.options.baseUrl = '';
  }

  /// GET request wrapped in [Result].
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _execute(() => _dio.get<T>(
          path,
          queryParameters: queryParameters,
        ));
  }

  /// POST request wrapped in [Result].
  Future<Result<T>> post<T>(
    String path, {
    Object? data,
  }) async {
    return _execute(() => _dio.post<T>(path, data: data));
  }

  /// PUT request wrapped in [Result].
  Future<Result<T>> put<T>(
    String path, {
    Object? data,
  }) async {
    return _execute(() => _dio.put<T>(path, data: data));
  }

  /// DELETE request wrapped in [Result].
  Future<Result<T>> delete<T>(String path) async {
    return _execute(() => _dio.delete<T>(path));
  }

  /// Executes a Dio request and maps exceptions to [Result.failure].
  Future<Result<T>> _execute<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      final response = await request();
      return Success(response.data as T);
    } on DioException catch (e, st) {
      return Failure(_mapDioException(e, st));
    } on Exception catch (e, st) {
      return Failure(UnknownException(e.toString(), st));
    }
  }

  /// Maps [DioException] types to our [AppException] hierarchy.
  AppException _mapDioException(DioException e, StackTrace st) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        TimeoutException(
          'Request timed out: ${e.requestOptions.path}',
          st,
        ),
      DioExceptionType.badResponse => _mapStatusCode(e, st),
      DioExceptionType.connectionError => NetworkException(
          'Connection failed: ${e.message}',
          stackTrace: st,
        ),
      DioExceptionType.cancel => NetworkException(
          'Request cancelled',
          stackTrace: st,
        ),
      _ => UnknownException(
          'Unknown network error: ${e.message} (${e.error})',
          st,
        ),
    };
  }

  /// Maps HTTP status codes to specific exception types.
  AppException _mapStatusCode(DioException e, StackTrace st) {
    final statusCode = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    String? detail;
    if (data is Map<String, dynamic>) {
      detail = (data['detail'] as String?) ?? (data['title'] as String?);
    }
    final message = detail ?? e.response?.statusMessage ?? 'Unknown error';

    return switch (statusCode) {
      401 => UnauthorizedException(
          detail ?? 'Session expired or invalid',
          st,
        ),
      404 => NotFoundException(
          detail ?? 'Resource not found: ${e.requestOptions.path}',
          st,
        ),
      _ => ServerException(
          message,
          statusCode: statusCode,
          serverMessage: data?.toString(),
          stackTrace: st,
        ),
    };
  }
}

/// Logs HTTP requests and responses for debugging.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logger.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      '✖ ${err.requestOptions.method} ${err.requestOptions.uri}',
      error: err.message,
    );
    handler.next(err);
  }
}

/// Simple retry interceptor for transient failures.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const _maxRetries = 2;
  static const _retryableStatusCodes = {408, 429, 500, 502, 503, 504};

  RetryInterceptor(this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final isRetryable = statusCode != null &&
        _retryableStatusCodes.contains(statusCode);

    if (!isRetryable) {
      handler.next(err);
      return;
    }

    final retryCount =
        err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= _maxRetries) {
      handler.next(err);
      return;
    }

    // Exponential backoff: 1s, 2s
    final delay = Duration(seconds: retryCount + 1);
    logger.w('⟳ Retry ${retryCount + 1}/$_maxRetries after ${delay.inSeconds}s');
    await Future<void>.delayed(delay);

    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      final response = await _dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
