import 'dart:io' show FileSystemException;
import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:network_module/dio_client.dart' show DioClient;
import 'package:network_module/network_exception.dart';

// --- Mock Classes ---
class MockDio extends Mock implements Dio {}

class MockCacheOptions extends Mock implements CacheOptions {}

class MockResponse<T> extends Mock implements Response<T> {}

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

// --- Concrete Test Implementation ---
class TestDioClient extends DioClient {
  TestDioClient({
    required super.dioClient,
    super.globalCacheOptions,
    super.interceptors,
    super.httpClientAdapter,
  });
}

void main() {
  // --- Test Setup ---
  late MockDio mockDio;
  late TestDioClient dioClient;
  late RequestOptions requestOptions;

  final globalCacheOptions = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
  );
  final specificCacheOptions = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.forceCache,
  );

  late MockResponse<dynamic> mockGetSuccessResponse;
  late MockResponse<List<int>> mockFetchSuccessResponse;
  late MockResponse<dynamic> mockPostSuccessResponse;
  late MockResponse<dynamic> mockPutSuccessResponse;
  late MockResponse<dynamic> mockDeleteSuccessResponse;
  late MockResponse<dynamic> mockDownloadSuccessResponse;

  // Helper Function: createDioException
  DioException createDioException(
    DioExceptionType type, {
    Response? response,
    dynamic error,
  }) {
    return DioException(
      requestOptions:
          requestOptions, // Assumes requestOptions is initialized in setUp
      type: type,
      response: response,
      error: error,
      message: 'Test DioException: $type',
    );
  }

  // Helper Function: createMockResponse
  MockResponse<T> createMockResponse<T>({
    required RequestOptions reqOptions,
    int statusCode = 200,
    T? data,
  }) {
    final response = MockResponse<T>();
    when(() => response.statusCode).thenReturn(statusCode);
    when(() => response.data).thenReturn(data);
    when(() => response.requestOptions).thenReturn(reqOptions);
    return response;
  }

  setUp(() {
    mockDio = MockDio();
    dioClient = TestDioClient(
      dioClient: mockDio,
    ); // Default client without global options

    requestOptions = RequestOptions(path: '/test');

    mockGetSuccessResponse = createMockResponse(
      reqOptions: requestOptions,
      statusCode: 200,
      data: 'Success',
    );
    mockFetchSuccessResponse = createMockResponse<List<int>>(
      reqOptions: requestOptions,
      statusCode: 200,
      data: Uint8List.fromList([1, 2, 3]),
    );
    mockPostSuccessResponse = createMockResponse(
      reqOptions: requestOptions,
      statusCode: 201,
      data: {'id': 'new_id'},
    );
    mockPutSuccessResponse = createMockResponse(
      reqOptions: requestOptions,
      statusCode: 200,
      data: {'id': '123', 'name': 'updated_test'},
    );
    mockDeleteSuccessResponse = createMockResponse(
      reqOptions: requestOptions,
      statusCode: 204,
      data: null,
    );
    mockDownloadSuccessResponse = createMockResponse<dynamic>(
      reqOptions: requestOptions,
      statusCode: 200,
      data: null,
    );
  });

  group('DioClient', () {
    group('Constructor', () {
      // ... constructor tests ...
      test('should add interceptors if provided', () {
        final mockInterceptor = Interceptor();
        final interceptors = [mockInterceptor];
        final dioForInterceptorTest = MockDio();
        when(
          () => dioForInterceptorTest.interceptors,
        ).thenReturn(Interceptors());
        TestDioClient(
          dioClient: dioForInterceptorTest,
          interceptors: interceptors,
        );
        verify(
          () => dioForInterceptorTest.interceptors.addAll(interceptors),
        ).called(1);
      });
      test('should set httpClientAdapter if provided', () {
        final mockAdapter = MockHttpClientAdapter();
        final dioForAdapterTest = MockDio();
        TestDioClient(
          dioClient: dioForAdapterTest,
          httpClientAdapter: mockAdapter,
        );
        verify(
          () => dioForAdapterTest.httpClientAdapter = mockAdapter,
        ).called(1);
      });
    });

    group('GET Requests', () {
      // --- Previously verified GET tests ---
      const testUrl = '/get_test';
      final testParams = {'id': '123'};

      test('should return Response on successful request (200 OK)', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => mockGetSuccessResponse);
        final result = await dioClient.get(testUrl);
        expect(result, isA<Response>());
        expect(result.data, 'Success');
        verify(
          () => mockDio.get(
            testUrl,
            queryParameters: null,
            options: null,
            cancelToken: null,
            onReceiveProgress: null,
          ),
        ).called(1);
      });

      test('should pass queryParameters correctly', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => mockGetSuccessResponse);
        await dioClient.get(testUrl, queryParameters: testParams);
        verify(
          () => mockDio.get(
            testUrl,
            queryParameters: testParams,
            options: null,
            cancelToken: null,
            onReceiveProgress: null,
          ),
        ).called(1);
      });

      test('should merge Dio Options and CacheOptions correctly', () async {
        final dioOptions = Options(headers: {'X-Custom': 'dio'});
        when(
          () => mockDio.get(
            any(),
            options: any(named: 'options'),
            queryParameters: any(named: 'queryParameters'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => mockGetSuccessResponse);
        await dioClient.get(
          testUrl,
          options: dioOptions,
          cacheOptions: specificCacheOptions,
        );
        final captured =
            verify(
              () => mockDio.get(
                testUrl,
                queryParameters: null,
                cancelToken: null,
                onReceiveProgress: null,
                options: captureAny(named: 'options'),
              ),
            ).captured;
        final capturedOptions = captured.first as Options?;
        expect(capturedOptions, isNotNull);
        expect(capturedOptions?.headers?['X-Custom'], 'dio');
        expect(capturedOptions?.extra?.containsKey('@cache_options@'), isTrue);
        final capturedCacheOptions =
            capturedOptions?.extra?['@cache_options@'] as CacheOptions?;
        expect(
          capturedCacheOptions?.policy,
          equals(specificCacheOptions.policy),
        );
      });

      test('should use globalCacheOptions if specific are null', () async {
        dioClient = TestDioClient(
          dioClient: mockDio,
          globalCacheOptions: globalCacheOptions,
        );
        when(
          () => mockDio.get(
            any(),
            options: any(named: 'options'),
            queryParameters: any(named: 'queryParameters'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => mockGetSuccessResponse);
        await dioClient.get(testUrl);
        final captured =
            verify(
              () => mockDio.get(
                testUrl,
                queryParameters: null,
                cancelToken: null,
                onReceiveProgress: null,
                options: captureAny(named: 'options'),
              ),
            ).captured;
        final capturedOptions = captured.first as Options?;
        expect(capturedOptions, isNotNull);
        expect(capturedOptions?.extra?.containsKey('@cache_options@'), isTrue);
        final capturedCacheOptions =
            capturedOptions?.extra?['@cache_options@'] as CacheOptions?;
        expect(capturedCacheOptions?.policy, equals(globalCacheOptions.policy));
      });

      // --- GET Error Handling Tests (already verified) ---
      test(
        'should throw NetworkTimeoutException on connectionTimeout',
        () async {
          final exception = createDioException(
            DioExceptionType.connectionTimeout,
          );
          when(
            () => mockDio.get(
              any(),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.get(testUrl),
            throwsA(isA<NetworkTimeoutException>()),
          );
        },
      );
      test(
        'should throw NetworkResponseException (400 Bad Request) on badResponse 400',
        () async {
          final mockErrorResponse = createMockResponse(
            reqOptions: requestOptions,
            statusCode: 400,
            data: {'error': 'Invalid input'},
          );
          final exception = createDioException(
            DioExceptionType.badResponse,
            response: mockErrorResponse,
          );
          when(
            () => mockDio.get(
              any(),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.get(testUrl),
            throwsA(
              isA<NetworkResponseException>()
                  .having((e) => e.code, 'code', NetworkErrorCode.badRequest)
                  .having((e) => e.statusCode, 'statusCode', 400)
                  .having((e) => e.responseData, 'responseData', {
                    'error': 'Invalid input',
                  }),
            ),
          );
        },
      );
      // ... other GET error tests ...
      test(
        'should throw UnknownNetworkErrorException for non-Dio exceptions',
        () async {
          final exception = Exception('Something completely unexpected!');
          when(
            () => mockDio.get(
              any(),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.get(testUrl),
            throwsA(
              isA<UnknownNetworkErrorException>().having(
                (e) => e.originalError,
                'originalError',
                exception,
              ),
            ),
          );
        },
      );
    });

    // --- POST Method Group ---
    group('POST Requests', () {
      const testUrl = '/post_test';
      final testData = {'name': 'test'};
      final testParams = {'source': 'app'};

      test(
        'should return Response on successful request (201 Created)',
        () async {
          when(
            () => mockDio.post(
              testUrl,
              data: any(named: 'data'),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenAnswer((_) async => mockPostSuccessResponse);

          final result = await dioClient.post(
            testUrl,
            data: testData,
            queryParameters: testParams,
          );

          expect(result, isA<Response>());
          expect(result.statusCode, 201);
          expect(result.data, {'id': 'new_id'});
          verify(
            () => mockDio.post(
              testUrl,
              data: testData,
              queryParameters: testParams,
              options: null,
              cancelToken: null,
              onSendProgress: null,
              onReceiveProgress: null,
            ),
          ).called(1);
        },
      );

      test(
        'should merge Dio Options and CacheOptions correctly for POST',
        () async {
          final dioOptions = Options(contentType: Headers.jsonContentType);
          when(
            () => mockDio.post(
              any(),
              data: any(named: 'data'),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenAnswer((_) async => mockPostSuccessResponse);

          await dioClient.post(
            testUrl,
            data: testData,
            options: dioOptions,
            cacheOptions: specificCacheOptions,
          );

          final captured =
              verify(
                () => mockDio.post(
                  testUrl,
                  data: testData,
                  queryParameters: null,
                  cancelToken: null,
                  onSendProgress: null,
                  onReceiveProgress: null,
                  options: captureAny(named: 'options'),
                ),
              ).captured;
          final capturedOptions = captured.first as Options?;
          expect(capturedOptions, isNotNull);
          expect(capturedOptions?.contentType, Headers.jsonContentType);
          expect(
            capturedOptions?.extra?.containsKey('@cache_options@'),
            isTrue,
          );
          final capturedCacheOptions =
              capturedOptions?.extra?['@cache_options@'] as CacheOptions?;
          expect(
            capturedCacheOptions?.policy,
            equals(specificCacheOptions.policy),
          );
        },
      );

      test(
        'should use globalCacheOptions if specific are null for POST',
        () async {
          dioClient = TestDioClient(
            dioClient: mockDio,
            globalCacheOptions: globalCacheOptions,
          );
          when(
            () => mockDio.post(
              any(),
              data: any(named: 'data'),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenAnswer((_) async => mockPostSuccessResponse);

          await dioClient.post(testUrl, data: testData);

          final captured =
              verify(
                () => mockDio.post(
                  testUrl,
                  data: testData,
                  queryParameters: null,
                  cancelToken: null,
                  onSendProgress: null,
                  onReceiveProgress: null,
                  options: captureAny(named: 'options'),
                ),
              ).captured;
          final capturedOptions = captured.first as Options?;
          expect(capturedOptions, isNotNull);
          expect(
            capturedOptions?.extra?.containsKey('@cache_options@'),
            isTrue,
          );
          final capturedCacheOptions =
              capturedOptions?.extra?['@cache_options@'] as CacheOptions?;
          expect(
            capturedCacheOptions?.policy,
            equals(globalCacheOptions.policy),
          );
        },
      );

      // --- POST Error Handling ---
      test('should throw NetworkTimeoutException on sendTimeout', () async {
        final exception = createDioException(DioExceptionType.sendTimeout);
        when(
          () => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            queryParameters: any(named: 'queryParameters'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.post(testUrl, data: testData),
          throwsA(isA<NetworkTimeoutException>()),
        );
      });

      test(
        'should throw NetworkResponseException (401 Unauthorized) on badResponse 401',
        () async {
          final mockErrorResponse = createMockResponse(
            reqOptions: requestOptions,
            statusCode: 401,
          );
          final exception = createDioException(
            DioExceptionType.badResponse,
            response: mockErrorResponse,
          );
          when(
            () => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.post(testUrl, data: testData),
            throwsA(
              isA<NetworkResponseException>().having(
                (e) => e.code,
                'code',
                NetworkErrorCode.unauthorized,
              ),
            ),
          );
        },
      );

      test('should throw NetworkCancelException on request cancel', () async {
        final exception = createDioException(DioExceptionType.cancel);
        when(
          () => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            queryParameters: any(named: 'queryParameters'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.post(testUrl, data: testData),
          throwsA(isA<NetworkCancelException>()),
        );
      });

      test(
        'should throw NetworkConnectionException on connectionError',
        () async {
          final exception = createDioException(
            DioExceptionType.connectionError,
          );
          when(
            () => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.post(testUrl, data: testData),
            throwsA(
              isA<NetworkConnectionException>().having(
                (e) => e.code,
                'code',
                NetworkErrorCode.connectionRefused,
              ),
            ),
          );
        },
      );

      test(
        'should throw UnknownNetworkErrorException for non-Dio exceptions',
        () async {
          final exception = ArgumentError('Invalid argument');
          when(
            () => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.post(testUrl, data: testData),
            throwsA(
              isA<UnknownNetworkErrorException>().having(
                (e) => e.originalError,
                'originalError',
                exception,
              ),
            ),
          );
        },
      );
      // ... Add other POST error tests if needed (e.g., different status codes, unknown, ssl) ...
    });

    // --- PUT Method Group ---
    group('PUT Requests', () {
      const testUrl = '/put_test/123';
      final testData = {'name': 'updated_test'};

      test('should return Response on successful request (200 OK)', () async {
        when(
          () => mockDio.put(
            testUrl,
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => mockPutSuccessResponse);

        final result = await dioClient.put(testUrl, data: testData);

        expect(result, isA<Response>());
        expect(result.statusCode, 200);
        expect(result.data, {'id': '123', 'name': 'updated_test'});
        verify(
          () => mockDio.put(
            testUrl,
            data: testData,
            options: null,
            queryParameters: null,
            cancelToken: null,
            onSendProgress: null,
            onReceiveProgress: null,
          ),
        ).called(1);
      });

      test(
        'should merge Dio Options and CacheOptions correctly for PUT',
        () async {
          final dioOptions = Options(extra: {'custom-put': true});
          when(
            () => mockDio.put(
              any(),
              data: any(named: 'data'),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenAnswer((_) async => mockPutSuccessResponse);

          await dioClient.put(
            testUrl,
            data: testData,
            options: dioOptions,
            cacheOptions: specificCacheOptions,
          );

          final captured =
              verify(
                () => mockDio.put(
                  testUrl,
                  data: testData,
                  queryParameters: null,
                  cancelToken: null,
                  onSendProgress: null,
                  onReceiveProgress: null,
                  options: captureAny(named: 'options'),
                ),
              ).captured;
          final capturedOptions = captured.first as Options?;
          expect(capturedOptions, isNotNull);
          expect(
            capturedOptions?.extra?['custom-put'],
            true,
          ); // Check Dio extra
          expect(
            capturedOptions?.extra?.containsKey('@cache_options@'),
            isTrue,
          );
          final capturedCacheOptions =
              capturedOptions?.extra?['@cache_options@'] as CacheOptions?;
          expect(
            capturedCacheOptions?.policy,
            equals(specificCacheOptions.policy),
          ); // Check cache extra
        },
      );

      // --- PUT Error Handling ---
      test(
        'should throw NetworkResponseException (404 Not Found) on badResponse 404',
        () async {
          final mockErrorResponse = createMockResponse(
            reqOptions: requestOptions,
            statusCode: 404,
          );
          final exception = createDioException(
            DioExceptionType.badResponse,
            response: mockErrorResponse,
          );
          when(
            () => mockDio.put(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.put(testUrl, data: testData),
            throwsA(
              isA<NetworkResponseException>().having(
                (e) => e.code,
                'code',
                NetworkErrorCode.notFound,
              ),
            ),
          );
        },
      );

      test(
        'should throw NetworkResponseException (500 Server Error) on badResponse 500',
        () async {
          final mockErrorResponse = createMockResponse(
            reqOptions: requestOptions,
            statusCode: 500,
          );
          final exception = createDioException(
            DioExceptionType.badResponse,
            response: mockErrorResponse,
          );
          when(
            () => mockDio.put(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.put(testUrl, data: testData),
            throwsA(
              isA<NetworkResponseException>().having(
                (e) => e.code,
                'code',
                NetworkErrorCode.serverError,
              ),
            ),
          );
        },
      );

      test('should throw NetworkSSLException on badCertificate', () async {
        final exception = createDioException(DioExceptionType.badCertificate);
        when(
          () => mockDio.put(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            queryParameters: any(named: 'queryParameters'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.put(testUrl, data: testData),
          throwsA(isA<NetworkSSLException>()),
        );
      });

      test(
        'should throw UnknownNetworkErrorException for non-Dio exceptions',
        () async {
          final exception = StateError('Bad state');
          when(
            () => mockDio.put(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
              queryParameters: any(named: 'queryParameters'),
              cancelToken: any(named: 'cancelToken'),
              onSendProgress: any(named: 'onSendProgress'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.put(testUrl, data: testData),
            throwsA(
              isA<UnknownNetworkErrorException>().having(
                (e) => e.originalError,
                'originalError',
                exception,
              ),
            ),
          );
        },
      );
      // ... Add other PUT error tests if needed ...
    });

    // --- DELETE Method Group ---
    group('DELETE Requests', () {
      const testUrl = '/delete_test/123';

      test(
        'should return Response on successful request (204 No Content)',
        () async {
          when(
            () => mockDio.delete(
              testUrl,
              data: any(named: 'data'),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
            ),
          ).thenAnswer((_) async => mockDeleteSuccessResponse);

          final result = await dioClient.delete(testUrl);

          expect(result, isA<Response>());
          expect(result.statusCode, 204);
          expect(result.data, null);
          verify(
            () => mockDio.delete(
              testUrl,
              data: null,
              options: null,
              queryParameters: null,
              cancelToken: null,
            ),
          ).called(1);
        },
      );

      test(
        'should merge Dio Options and CacheOptions correctly for DELETE',
        () async {
          final dioOptions = Options(headers: {'X-Delete-Confirm': 'true'});
          when(
            () => mockDio.delete(
              any(),
              data: any(named: 'data'),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
            ),
          ).thenAnswer((_) async => mockDeleteSuccessResponse);

          await dioClient.delete(
            testUrl,
            options: dioOptions,
            cacheOptions: specificCacheOptions,
          );

          final captured =
              verify(
                () => mockDio.delete(
                  testUrl,
                  data: null,
                  queryParameters: null,
                  cancelToken: null,
                  options: captureAny(named: 'options'),
                ),
              ).captured;
          final capturedOptions = captured.first as Options?;
          expect(capturedOptions, isNotNull);
          expect(capturedOptions?.headers?['X-Delete-Confirm'], 'true');
          expect(
            capturedOptions?.extra?.containsKey('@cache_options@'),
            isTrue,
          );
          final capturedCacheOptions =
              capturedOptions?.extra?['@cache_options@'] as CacheOptions?;
          expect(
            capturedCacheOptions?.policy,
            equals(specificCacheOptions.policy),
          );
        },
      );

      // --- DELETE Error Handling ---
      test('should throw NetworkTimeoutException on receiveTimeout', () async {
        final exception = createDioException(DioExceptionType.receiveTimeout);
        when(
          () => mockDio.delete(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.delete(testUrl),
          throwsA(isA<NetworkTimeoutException>()),
        );
      });

      test(
        'should throw NetworkResponseException (403 Forbidden) on badResponse 403',
        () async {
          final mockErrorResponse = createMockResponse(
            reqOptions: requestOptions,
            statusCode: 403,
          );
          final exception = createDioException(
            DioExceptionType.badResponse,
            response: mockErrorResponse,
          );
          when(
            () => mockDio.delete(
              any(),
              data: any(named: 'data'),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.delete(testUrl),
            throwsA(
              isA<NetworkResponseException>().having(
                (e) => e.code,
                'code',
                NetworkErrorCode.forbidden,
              ),
            ),
          );
        },
      );

      test('should throw NetworkCancelException on request cancel', () async {
        final exception = createDioException(DioExceptionType.cancel);
        when(
          () => mockDio.delete(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.delete(testUrl),
          throwsA(isA<NetworkCancelException>()),
        );
      });

      test(
        'should throw UnknownNetworkErrorException for non-Dio exceptions',
        () async {
          final exception = FormatException('Bad format');
          when(
            () => mockDio.delete(
              any(),
              data: any(named: 'data'),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.delete(testUrl),
            throwsA(
              isA<UnknownNetworkErrorException>().having(
                (e) => e.originalError,
                'originalError',
                exception,
              ),
            ),
          );
        },
      );
      // ... Add other DELETE error tests if needed ...
    });

    // --- Fetch Method Group ---
    group('Fetch Requests', () {
      const testUrl = '/fetch_data.bin';
      final testParams = {'version': '1.0'};
      final expectedData = Uint8List.fromList([1, 2, 3]);

      test('should return Response<List<int>> on successful request', () async {
        // Arrange
        when(
          () => mockDio.get<List<int>>(
            // Ensure generic type matches
            testUrl,
            queryParameters: any(named: 'queryParameters'),
            options: any(
              named: 'options',
              that: isA<Options>().having(
                (o) => o.responseType,
                'responseType',
                ResponseType.bytes,
              ),
            ), // Verify responseType
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => mockFetchSuccessResponse);

        // Act
        final result = await dioClient.fetch(
          testUrl,
          queryParameters: testParams,
        );

        // Assert
        expect(result, isA<Response<List<int>>>());
        expect(result.data, equals(expectedData));
        expect(result.statusCode, 200);

        // Verify call with captured options to check responseType again
        final captured =
            verify(
              () => mockDio.get<List<int>>(
                testUrl,
                queryParameters: testParams,
                cancelToken: null,
                onReceiveProgress: null,
                options: captureAny(named: 'options'),
              ),
            ).captured;

        final capturedOptions = captured.first as Options?;
        expect(capturedOptions?.responseType, ResponseType.bytes);
      });

      test('should merge Dio Options and enforce ResponseType.bytes', () async {
        // Arrange
        final dioOptions = Options(
          headers: {'Accept': 'application/octet-stream'},
          responseType: ResponseType.json,
        ); // User mistakenly sets responseType
        when(
          () => mockDio.get<List<int>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => mockFetchSuccessResponse);

        // Act
        await dioClient.fetch(testUrl, options: dioOptions);

        // Assert
        final captured =
            verify(
              () => mockDio.get<List<int>>(
                testUrl,
                queryParameters: null,
                cancelToken: null,
                onReceiveProgress: null,
                options: captureAny(named: 'options'),
              ),
            ).captured;
        final capturedOptions = captured.first as Options?;
        expect(capturedOptions, isNotNull);
        // Verify ResponseType is BYTES, overriding user's JSON
        expect(capturedOptions?.responseType, ResponseType.bytes);
        // Verify other user options are kept
        expect(capturedOptions?.headers?['Accept'], 'application/octet-stream');
      });

      test('should merge CacheOptions correctly for Fetch', () async {
        // Arrange
        when(
          () => mockDio.get<List<int>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => mockFetchSuccessResponse);

        // Act
        await dioClient.fetch(testUrl, cacheOptions: specificCacheOptions);

        // Assert
        final captured =
            verify(
              () => mockDio.get<List<int>>(
                testUrl,
                queryParameters: null,
                cancelToken: null,
                onReceiveProgress: null,
                options: captureAny(named: 'options'),
              ),
            ).captured;
        final capturedOptions = captured.first as Options?;
        expect(capturedOptions, isNotNull);
        expect(
          capturedOptions?.responseType,
          ResponseType.bytes,
        ); // Still check this
        expect(capturedOptions?.extra?.containsKey('@cache_options@'), isTrue);
        final capturedCacheOptions =
            capturedOptions?.extra?['@cache_options@'] as CacheOptions?;
        expect(
          capturedCacheOptions?.policy,
          equals(specificCacheOptions.policy),
        );
      });

      test(
        'should use globalCacheOptions if specific are null for Fetch',
        () async {
          // Arrange
          dioClient = TestDioClient(
            dioClient: mockDio,
            globalCacheOptions: globalCacheOptions,
          );
          when(
            () => mockDio.get<List<int>>(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenAnswer((_) async => mockFetchSuccessResponse);

          // Act
          await dioClient.fetch(testUrl);

          // Assert
          final captured =
              verify(
                () => mockDio.get<List<int>>(
                  testUrl,
                  queryParameters: null,
                  cancelToken: null,
                  onReceiveProgress: null,
                  options: captureAny(named: 'options'),
                ),
              ).captured;
          final capturedOptions = captured.first as Options?;
          expect(capturedOptions, isNotNull);
          expect(capturedOptions?.responseType, ResponseType.bytes);
          expect(
            capturedOptions?.extra?.containsKey('@cache_options@'),
            isTrue,
          );
          final capturedCacheOptions =
              capturedOptions?.extra?['@cache_options@'] as CacheOptions?;
          expect(
            capturedCacheOptions?.policy,
            equals(globalCacheOptions.policy),
          );
        },
      );

      // --- Fetch Error Handling ---
      test(
        'should throw NetworkResponseException (404 Not Found) on badResponse 404',
        () async {
          final mockErrorResponse = createMockResponse<dynamic>(
            reqOptions: requestOptions,
            statusCode: 404,
          ); // Error response might not be List<int>
          final exception = createDioException(
            DioExceptionType.badResponse,
            response: mockErrorResponse,
          );
          when(
            () => mockDio.get<List<int>>(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.fetch(testUrl),
            throwsA(
              isA<NetworkResponseException>().having(
                (e) => e.code,
                'code',
                NetworkErrorCode.notFound,
              ),
            ),
          );
        },
      );

      test('should throw NetworkTimeoutException on timeout', () async {
        final exception = createDioException(
          DioExceptionType.connectionTimeout,
        );
        when(
          () => mockDio.get<List<int>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.fetch(testUrl),
          throwsA(isA<NetworkTimeoutException>()),
        );
      });

      test('should throw NetworkCancelException on request cancel', () async {
        final exception = createDioException(DioExceptionType.cancel);
        when(
          () => mockDio.get<List<int>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.fetch(testUrl),
          throwsA(isA<NetworkCancelException>()),
        );
      });

      test(
        'should throw UnknownNetworkErrorException for non-Dio exceptions',
        () async {
          final exception = FormatException('Bad format during processing');
          when(
            () => mockDio.get<List<int>>(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.fetch(testUrl),
            throwsA(
              isA<UnknownNetworkErrorException>().having(
                (e) => e.originalError,
                'originalError',
                exception,
              ),
            ),
          );
        },
      );
    });

    // --- Download Method Group ---
    group('Download Requests', () {
      const testUrl = '/download/file.zip';
      const testSavePath = '/fake/path/to/save/file.zip';
      final testParams = {'token': 'abc'};
      void mockProgressCallback(int count, int total) {} // Dummy callback

      test('should return Response on successful download', () async {
        // Arrange
        when(
          () => mockDio.download(
            testUrl,
            testSavePath, // Specific path
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            deleteOnError: any(named: 'deleteOnError'),
          ),
        ).thenAnswer((_) async => mockDownloadSuccessResponse);

        // Act
        final result = await dioClient.download(
          testUrl,
          testSavePath,
          queryParameters: testParams,
          onReceiveProgress: mockProgressCallback,
          deleteOnError: false, // Test passing non-default value
        );

        // Assert
        expect(result, isA<Response>());
        expect(
          result.statusCode,
          200,
        ); // Or whatever mockDownloadSuccessResponse has

        // Verify dio.download call with exact parameters
        verify(
          () => mockDio.download(
            testUrl,
            testSavePath,
            queryParameters: testParams,
            options: null, // Expect null if none provided
            cancelToken: null,
            onReceiveProgress: mockProgressCallback,
            deleteOnError: false,
          ),
        ).called(1);
      });

      test('should pass Options correctly (e.g., headers)', () async {
        // Arrange
        final dioOptions = Options(headers: {'Authorization': 'Bearer token'});
        when(
          () => mockDio.download(
            any(),
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            deleteOnError: any(named: 'deleteOnError'),
          ),
        ).thenAnswer((_) async => mockDownloadSuccessResponse);

        // Act
        await dioClient.download(testUrl, testSavePath, options: dioOptions);

        // Assert
        final captured =
            verify(
              () => mockDio.download(
                testUrl,
                testSavePath,
                queryParameters: null,
                cancelToken: null,
                onReceiveProgress: null,
                deleteOnError: true, // Default value
                options: captureAny(named: 'options'),
              ),
            ).captured;
        final capturedOptions = captured.first as Options?;
        expect(capturedOptions, isNotNull);
        expect(capturedOptions?.headers?['Authorization'], 'Bearer token');

        // Verify that either 'extra' is null OR it doesn't contain the cache key
        expect(
          capturedOptions?.extra == null ||
              !(capturedOptions!.extra!.containsKey('@cache_options@')),
          isTrue,
          reason:
              "Cache options should not be present in the 'extra' map for download",
        );
      });

      test('should NOT include cache options even if provided', () async {
        // Arrange
        dioClient = TestDioClient(
          dioClient: mockDio,
          globalCacheOptions: globalCacheOptions,
        ); // Set global cache
        when(
          () => mockDio.download(
            any(),
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            deleteOnError: any(named: 'deleteOnError'),
          ),
        ).thenAnswer((_) async => mockDownloadSuccessResponse);

        // Act
        await dioClient.download(
          testUrl,
          testSavePath,
          // cacheOptions: specificCacheOptions,
        ); // Provide specific too

        // Assert
        final captured =
            verify(
              () => mockDio.download(
                testUrl,
                testSavePath,
                queryParameters: null,
                cancelToken: null,
                onReceiveProgress: null,
                deleteOnError: true,
                options: captureAny(named: 'options'),
              ),
            ).captured;
        final capturedOptions = captured.first as Options?;

        // --- CORRECTED ASSERTION for cache options absence ---
        // Verify that either 'extra' is null OR it doesn't contain the cache key
        expect(
          capturedOptions?.extra == null ||
              !(capturedOptions!.extra!.containsKey('@cache_options@')),
          isTrue,
          reason:
              "Cache options should not be present in the 'extra' map for download, even if provided",
        );
      });

      // --- Download Error Handling ---
      test(
        'should throw NetworkResponseException (403 Forbidden) on badResponse 403',
        () async {
          final mockErrorResponse = createMockResponse<dynamic>(
            reqOptions: requestOptions,
            statusCode: 403,
          );
          final exception = createDioException(
            DioExceptionType.badResponse,
            response: mockErrorResponse,
          );
          when(
            () => mockDio.download(
              any(),
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
              deleteOnError: any(named: 'deleteOnError'),
            ),
          ).thenThrow(exception);
          expect(
            () => dioClient.download(testUrl, testSavePath),
            throwsA(
              isA<NetworkResponseException>().having(
                (e) => e.code,
                'code',
                NetworkErrorCode.forbidden,
              ),
            ),
          );
        },
      );

      test('should throw NetworkTimeoutException on timeout', () async {
        final exception = createDioException(DioExceptionType.receiveTimeout);
        when(
          () => mockDio.download(
            any(),
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            deleteOnError: any(named: 'deleteOnError'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.download(testUrl, testSavePath),
          throwsA(isA<NetworkTimeoutException>()),
        );
      });

      test('should throw NetworkCancelException on request cancel', () async {
        final exception = createDioException(DioExceptionType.cancel);
        when(
          () => mockDio.download(
            any(),
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            deleteOnError: any(named: 'deleteOnError'),
          ),
        ).thenThrow(exception);
        expect(
          () => dioClient.download(testUrl, testSavePath),
          throwsA(isA<NetworkCancelException>()),
        );
      });

      // Simulate FileSystem Error wrapped by Dio (often comes as Unknown or ConnectionError)
      test(
        'should throw NetworkConnectionException (or related) on DioExceptionType.unknown from download',
        () async {
          // Dio might wrap file system errors (like path not found) as 'unknown'
          final fileSystemError = FileSystemException(
            'Cannot open file',
            testSavePath,
          );
          final exception = createDioException(
            DioExceptionType.unknown,
            error: fileSystemError,
          );
          when(
            () => mockDio.download(
              any(),
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
              deleteOnError: any(named: 'deleteOnError'),
            ),
          ).thenThrow(exception);
          // Check against the code mapped in _handleDioError for 'unknown'
          expect(
            () => dioClient.download(testUrl, testSavePath),
            throwsA(
              isA<NetworkConnectionException>().having(
                (e) => e.code,
                'code',
                NetworkErrorCode.networkUnreachable,
              ),
            ),
          );
        },
      );

      // Simulate FileSystem Error *NOT* wrapped by Dio
      test(
        'should throw UnknownNetworkErrorException for non-Dio filesystem exceptions',
        () async {
          // Simulate an error happening outside Dio's direct handling during download
          final exception = FileSystemException(
            'Permission denied',
            testSavePath,
          );
          when(
            () => mockDio.download(
              any(),
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
              deleteOnError: any(named: 'deleteOnError'),
            ),
          ).thenThrow(exception); // Throw the raw exception
          expect(
            () => dioClient.download(testUrl, testSavePath),
            throwsA(
              isA<UnknownNetworkErrorException>()
                  .having((e) => e.code, 'code', NetworkErrorCode.unknownError)
                  .having(
                    (e) => e.originalError,
                    'originalError',
                    exception,
                  ), // Check original error
            ),
          );
        },
      );
    });
  }); // End DioClient Group
} // End main
