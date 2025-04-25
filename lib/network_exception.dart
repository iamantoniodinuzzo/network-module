import 'package:dio/dio.dart';

/// Enum defining specific, stable codes for different network errors.
/// These codes should be used by the consuming application for localization.
enum NetworkErrorCode {
  // Connection Errors
  connectionTimeout, // Request timed out
  connectionRefused, // Explicit connection error (e.g., refused)
  connectionDioError, // Other Dio connectionError type
  sslError,          // SSL certificate issue
  networkUnreachable, // Generic connection issue (often from Dio unknown type)

  // Response Errors
  badRequest,        // 400
  unauthorized,      // 401
  forbidden,         // 403
  notFound,          // 404
  serverError,       // 5xx
  responseUnhandled, // Other non-2xx status code not specifically handled

  // Other Errors
  requestCancelled,    // Request was cancelled
  serializationError, // Error during data processing (if you add this later)
  unknownError,      // Fallback for truly unexpected errors
  dioUnhandledError, // Fallback for unhandled DioException types
}


/// Base class for all network-related exceptions handled within the application.
///
/// Contains structured data about the error, including a stable [code] for localization
/// and a default English [message] for debugging or fallback.
abstract class NetworkException implements Exception {

  /// A stable error code representing the type of network error.
  /// Use this code in the application layer to look up localized messages.
  final NetworkErrorCode code;

  /// A default diagnostic message in English. Can be used as a fallback
  /// if localization for the specific [code] is not available.
  final String message;

  /// The HTTP status code associated with the error, if available.
  final int? statusCode;

  /// Creates a [NetworkException] instance.
  const NetworkException(
    this.message, {
    required this.code,
    this.statusCode,
  });

  @override
  String toString() =>
      'NetworkException(code: $code, message: $message${statusCode != null ? ', statusCode: $statusCode' : ''})';
}

// --- Specific Network Exception Subclasses ---

class NetworkTimeoutException extends NetworkException {
  /// Creates a [NetworkTimeoutException].
  NetworkTimeoutException([
      super.message = 'Network request timed out.', // Default English message
      NetworkErrorCode code = NetworkErrorCode.connectionTimeout // Specific code
  ]) : super(code: code);
}

class NetworkResponseException extends NetworkException {
  final dynamic responseData;

  /// Creates a [NetworkResponseException].
  const NetworkResponseException({
    required String message,
    required super.code, // Must provide a code
    required super.statusCode,
    this.responseData,
  }) : super(message); // Pass message to base constructor

  /// Factory constructor to create a [NetworkResponseException] from a [DioException].
  factory NetworkResponseException.fromDioException(DioException err) {
    assert(err.type == DioExceptionType.badResponse);

    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;
    String message;
    NetworkErrorCode code;

    switch (statusCode) {
      case 400:
        message = 'Bad Request (400)';
        code = NetworkErrorCode.badRequest;
        break;
      case 401:
        message = 'Unauthorized (401)';
        code = NetworkErrorCode.unauthorized;
        break;
      case 403:
        message = 'Forbidden (403)';
        code = NetworkErrorCode.forbidden;
        break;
      case 404:
        message = 'Not Found (404)';
        code = NetworkErrorCode.notFound;
        break;
      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        message = 'Internal Server Error ($statusCode)';
        code = NetworkErrorCode.serverError;
        break;
      default:
        message = 'Unhandled Server Response Status Code: $statusCode';
        code = NetworkErrorCode.responseUnhandled;
        break;
    }

    return NetworkResponseException(
      message: message, // Default English/debug message
      code: code,       // The crucial code for localization
      statusCode: statusCode,
      responseData: responseData,
    );
  }

   @override
  String toString() =>
      'NetworkResponseException(code: $code, message: $message, statusCode: $statusCode${responseData != null ? ', responseData available)' : ')'}';
}

class NetworkCancelException extends NetworkException {
  /// Creates a [NetworkCancelException].
  const NetworkCancelException([
    super.message = 'Network request was cancelled.',
    NetworkErrorCode code = NetworkErrorCode.requestCancelled
  ]) : super(code: code);
}

class NetworkConnectionException extends NetworkException {
   /// Creates a [NetworkConnectionException].
   /// Requires specifying the underlying reason via the [code].
  const NetworkConnectionException({
    required String message, // Provide a specific default message
    required super.code,   // e.g., connectionRefused, networkUnreachable
  }) : super(message);
}

class NetworkSSLException extends NetworkException {
  /// Creates a [NetworkSSLException].
  const NetworkSSLException([
    super.message = 'SSL certificate validation failed.',
    NetworkErrorCode code = NetworkErrorCode.sslError
  ]) : super(code: code);
}


class UnknownNetworkErrorException extends NetworkException {
  final Object? originalError;

  /// Creates an [UnknownNetworkErrorException].
  const UnknownNetworkErrorException({
    String message = 'An unknown network error occurred.',
    required super.code, // e.g., unknownError, dioUnhandledError
    this.originalError,
  }) : super(message);

  @override
  String toString() =>
      'UnknownNetworkErrorException(code: $code, message: $message${originalError != null ? ', originalError: $originalError)' : ')'}';
}