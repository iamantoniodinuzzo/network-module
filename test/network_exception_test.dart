import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_module/network_exception.dart';

void main() {
  group('NetworkException Tests', () {
    group('NetworkResponseException', () {
      test('should create NetworkResponseException with all properties', () {
        const exception = NetworkResponseException(
          message: 'Response error',
          code: NetworkErrorCode.badRequest,
          statusCode: 400,
          responseData: {'error': 'Bad request'},
        );

        expect(exception.message, 'Response error');
        expect(exception.code, NetworkErrorCode.badRequest);
        expect(exception.statusCode, 400);
        expect(exception.responseData, {'error': 'Bad request'});
      });

      test('should create NetworkResponseException without responseData', () {
        const exception = NetworkResponseException(
          message: 'Response error',
          code: NetworkErrorCode.badRequest,
          statusCode: 400,
        );

        expect(exception.message, 'Response error');
        expect(exception.code, NetworkErrorCode.badRequest);
        expect(exception.statusCode, 400);
        expect(exception.responseData, isNull);
      });

      group('fromDioException factory', () {
        late RequestOptions requestOptions;

        setUp(() {
          requestOptions = RequestOptions(path: '/test');
        });

        test('should create from DioException with 400 status', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 400,
              data: {'error': 'Bad request'},
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.badRequest);
          expect(exception.statusCode, 400);
          expect(exception.responseData, {'error': 'Bad request'});
          expect(exception.message, 'Bad Request (400)');
        });

        test('should create from DioException with 401 status', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 401,
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.unauthorized);
          expect(exception.statusCode, 401);
          expect(exception.message, 'Unauthorized (401)');
        });

        test('should create from DioException with 403 status', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 403,
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.forbidden);
          expect(exception.statusCode, 403);
          expect(exception.message, 'Forbidden (403)');
        });

        test('should create from DioException with 404 status', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 404,
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.notFound);
          expect(exception.statusCode, 404);
          expect(exception.message, 'Not Found (404)');
        });

        test('should create from DioException with 500 status', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 500,
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.serverError);
          expect(exception.statusCode, 500);
          expect(exception.message, 'Internal Server Error (500)');
        });

        test('should create from DioException with 502 status', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 502,
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.serverError);
          expect(exception.statusCode, 502);
          expect(exception.message, 'Internal Server Error (502)');
        });

        test('should create from DioException with 503 status', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 503,
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.serverError);
          expect(exception.statusCode, 503);
          expect(exception.message, 'Internal Server Error (503)');
        });

        test('should create from DioException with 504 status', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 504,
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.serverError);
          expect(exception.statusCode, 504);
          expect(exception.message, 'Internal Server Error (504)');
        });

        test('should handle unhandled status codes', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 418, // I'm a teapot
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.responseUnhandled);
          expect(exception.statusCode, 418);
          expect(
            exception.message,
            'Unhandled Server Response Status Code: 418',
          );
        });

        test('should handle null status code', () {
          final dioException = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: requestOptions,
            ),
          );

          final exception =
              NetworkResponseException.fromDioException(dioException);

          expect(exception.code, NetworkErrorCode.responseUnhandled);
          expect(exception.statusCode, isNull);
          expect(
            exception.message,
            'Unhandled Server Response Status Code: null',
          );
        });
      });

      test('toString should include statusCode when present', () {
        const exception = NetworkResponseException(
          message: 'Test message',
          code: NetworkErrorCode.badRequest,
          statusCode: 400,
        );

        final string = exception.toString();
        expect(string, contains('NetworkResponseException'));
        expect(string, contains('statusCode: 400'));
      });

      test('toString should include responseData availability', () {
        const exception = NetworkResponseException(
          message: 'Test message',
          code: NetworkErrorCode.badRequest,
          statusCode: 400,
          responseData: {'error': 'test'},
        );

        final string = exception.toString();
        expect(string, contains('responseData available'));
      });
    });

    group('NetworkTimeoutException', () {
      test('should create with default values', () {
        final exception = NetworkTimeoutException();

        expect(exception.message, 'Network request timed out.');
        expect(exception.code, NetworkErrorCode.connectionTimeout);
      });

      test('should create with custom message', () {
        final exception = NetworkTimeoutException('Custom timeout message');

        expect(exception.message, 'Custom timeout message');
        expect(exception.code, NetworkErrorCode.connectionTimeout);
      });

      test('should create with custom message and code', () {
        final exception = NetworkTimeoutException(
          'Send timeout',
        );

        expect(exception.message, 'Send timeout');
        expect(exception.code, NetworkErrorCode.connectionTimeout);
      });
    });

    group('NetworkConnectionException', () {
      test('should create with required parameters', () {
        const exception = NetworkConnectionException(
          message: 'Connection failed',
          code: NetworkErrorCode.connectionRefused,
        );

        expect(exception.message, 'Connection failed');
        expect(exception.code, NetworkErrorCode.connectionRefused);
      });

      test('should create with network unreachable code', () {
        const exception = NetworkConnectionException(
          message: 'Network unreachable',
          code: NetworkErrorCode.networkUnreachable,
        );

        expect(exception.message, 'Network unreachable');
        expect(exception.code, NetworkErrorCode.networkUnreachable);
      });
    });

    group('NetworkCancelException', () {
      test('should create with default values', () {
        const exception = NetworkCancelException();

        expect(exception.message, 'Network request was cancelled.');
        expect(exception.code, NetworkErrorCode.requestCancelled);
      });

      test('should create with custom message', () {
        const exception = NetworkCancelException(
          'User cancelled request',
        );

        expect(exception.message, 'User cancelled request');
        expect(exception.code, NetworkErrorCode.requestCancelled);
      });
    });

    group('NetworkSSLException', () {
      test('should create with default values', () {
        const exception = NetworkSSLException();

        expect(exception.message, 'SSL certificate validation failed.');
        expect(exception.code, NetworkErrorCode.sslError);
      });

      test('should create with custom message', () {
        const exception = NetworkSSLException(
          'Certificate expired',
        );

        expect(exception.message, 'Certificate expired');
        expect(exception.code, NetworkErrorCode.sslError);
      });
    });

    group('UnknownNetworkErrorException', () {
      test('should create with all properties', () {
        const originalError = FormatException('Bad format');
        const exception = UnknownNetworkErrorException(
          message: 'Unknown error occurred',
          code: NetworkErrorCode.unknownError,
          originalError: originalError,
        );

        expect(exception.message, 'Unknown error occurred');
        expect(exception.code, NetworkErrorCode.unknownError);
        expect(exception.originalError, originalError);
      });

      test('should create with default message', () {
        const exception = UnknownNetworkErrorException(
          code: NetworkErrorCode.unknownError,
        );

        expect(exception.message, 'An unknown network error occurred.');
        expect(exception.code, NetworkErrorCode.unknownError);
        expect(exception.originalError, isNull);
      });

      test('toString should include originalError when present', () {
        const originalError = FormatException('Bad format');
        const exception = UnknownNetworkErrorException(
          message: 'Unknown error occurred',
          code: NetworkErrorCode.unknownError,
          originalError: originalError,
        );

        final string = exception.toString();
        expect(string, contains('UnknownNetworkErrorException'));
        expect(string, contains('originalError: FormatException: Bad format'));
      });

      test('toString should not include originalError when absent', () {
        const exception = UnknownNetworkErrorException(
          message: 'Unknown error occurred',
          code: NetworkErrorCode.unknownError,
        );

        final string = exception.toString();
        expect(string, contains('UnknownNetworkErrorException'));
        expect(string, isNot(contains('originalError:')));
      });
    });

    group('NetworkErrorCode enum', () {
      test('should have all expected error codes', () {
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.connectionTimeout),
        );
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.connectionRefused),
        );
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.connectionDioError),
        );
        expect(NetworkErrorCode.values, contains(NetworkErrorCode.sslError));
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.networkUnreachable),
        );
        expect(NetworkErrorCode.values, contains(NetworkErrorCode.badRequest));
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.unauthorized),
        );
        expect(NetworkErrorCode.values, contains(NetworkErrorCode.forbidden));
        expect(NetworkErrorCode.values, contains(NetworkErrorCode.notFound));
        expect(NetworkErrorCode.values, contains(NetworkErrorCode.serverError));
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.responseUnhandled),
        );
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.requestCancelled),
        );
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.serializationError),
        );
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.unknownError),
        );
        expect(
          NetworkErrorCode.values,
          contains(NetworkErrorCode.dioUnhandledError),
        );
      });

      test('should have correct number of error codes', () {
        expect(NetworkErrorCode.values.length, 15);
      });
    });

    group('Base NetworkException behavior', () {
      test('should implement Exception interface', () {
        const exception = NetworkResponseException(
          message: 'Test',
          code: NetworkErrorCode.badRequest,
          statusCode: 400,
        );

        expect(exception, isA<Exception>());
        expect(exception, isA<NetworkException>());
      });

      test('toString should include base information', () {
        const exception = NetworkConnectionException(
          message: 'Connection failed',
          code: NetworkErrorCode.connectionRefused,
        );

        final string = exception.toString();
        expect(string, contains('NetworkException'));
        expect(string, contains('Connection failed'));
        expect(string, contains('NetworkErrorCode.connectionRefused'));
      });
    });
  });
}
