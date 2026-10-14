/// Functional error handling using a sealed Result type.
///
/// Usage:
/// ```dart
/// final result = await repository.getProduct(id);
/// switch (result) {
///   case Success(:final data):
///     // handle data
///   case Failure(:final exception):
///     // handle error
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Whether this result is a success.
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a failure.
  bool get isFailure => this is Failure<T>;

  /// Maps the success value.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Success(transform(data)),
      Failure(:final exception) => Failure(exception),
    };
  }

  /// Flat-maps the success value.
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success(:final data) => transform(data),
      Failure(:final exception) => Failure(exception),
    };
  }

  /// Returns the data if success, or the fallback if failure.
  T getOrElse(T Function() fallback) {
    return switch (this) {
      Success(:final data) => data,
      Failure() => fallback(),
    };
  }
}

/// A successful result containing [data].
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// A failed result containing an [exception].
final class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);

  @override
  String toString() => 'Failure($exception)';
}

/// Base exception class for all app exceptions.
sealed class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a network request fails.
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(
    String message, {
    this.statusCode,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Thrown when the server returns an error response.
class ServerException extends AppException {
  final int statusCode;
  final String? serverMessage;

  const ServerException(
    String message, {
    required this.statusCode,
    this.serverMessage,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Thrown when a local cache operation fails.
class CacheException extends AppException {
  const CacheException(super.message, [super.stackTrace]);
}

/// Thrown when a request times out.
class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.stackTrace]);
}

/// Thrown when the user is not authenticated or the session expired.
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.stackTrace]);
}

/// Thrown when an operation is not found or the data is missing.
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.stackTrace]);
}

/// Thrown for unexpected or unknown errors.
class UnknownException extends AppException {
  const UnknownException(super.message, [super.stackTrace]);
}
