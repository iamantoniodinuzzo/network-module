import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:network_module/network_exception.dart';

/// An abstract base class for making network requests using the Dio package.
///
/// Provides standardized methods for common HTTP verbs (GET, POST, PUT, DELETE)
/// and specialized methods like [fetch] (for raw bytes) and [download] (to file).
/// Includes built-in error handling that converts [DioException]s into custom
/// [NetworkException]s, and integrates with [dio_cache_interceptor] for caching
/// (except for [download]).
///
/// Extend this class to create concrete API client implementations.
///
/// **Error Handling:**
/// All request methods catch [DioException] and translate them into specific
/// [NetworkException] subtypes based on the error type and response status.
/// Unexpected non-Dio errors are wrapped in [UnknownNetworkErrorException].
///
/// **Caching:**
/// Caching behavior can be controlled globally via [globalCacheOptions] passed
/// to the constructor, or per-request via the `cacheOptions` parameter on
/// methods like [get], [post], [put], [delete], and [fetch]. The [download]
/// method does *not* support caching.
///
/// **Retry Logic:**
/// This client does **not** implement automatic retry logic. Retries should be
/// handled externally, preferably by adding a retry interceptor (e.g., from
/// the `dio_smart_retry` package) to the [Dio] instance before passing it
/// to this client's constructor.
///
abstract class DioClient {
  /// Creates an instance of [DioClient].
  ///
  /// Requires a configured [Dio] instance ([dioClient]).
  /// Optionally accepts [globalCacheOptions] for default caching behavior,
  /// a list of [interceptors] to add to the Dio instance, and a custom
  /// [httpClientAdapter].
  DioClient({
    required Dio dioClient,
    this.globalCacheOptions,
    Iterable<Interceptor>? interceptors,
    HttpClientAdapter? httpClientAdapter,
  }) : _dio = dioClient {
    // Add provided interceptors to the Dio instance.
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
    // Set the custom HttpClientAdapter if provided.
    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
    }
  }

  /// The underlying [Dio] instance used for network communication.
  /// Protected to allow access in subclasses if needed, but primarily managed internally.
  final Dio _dio;

  /// Optional global cache options applied to requests if specific [cacheOptions]
  /// are not provided for a particular request.
  final CacheOptions? globalCacheOptions;

  /// Sends a GET request to the specified [url].
  ///
  /// - [url]: The request URL.
  /// - [queryParameters]: Optional URL query parameters.
  /// - [options]: Dio [Options] for this specific request (e.g., headers, response type).
  ///            These will be merged with [cacheOptions].
  /// - [cancelToken]: Optional [CancelToken] to allow cancelling the request externally.
  /// - [onReceiveProgress]: Optional callback for tracking download progress.
  /// - [cacheOptions]: Optional [CacheOptions] specific to this request.
  ///                 If null, [globalCacheOptions] will be used (if available).
  ///
  /// Returns a [Future<Response>] containing the raw Dio response upon success.
  ///
  /// Throws a [NetworkException] (or one of its subtypes like
  /// [NetworkTimeoutException], [NetworkResponseException], etc.) on failure.
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    CacheOptions? cacheOptions,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: _mergeDioAndCacheOptions(
          dioOptions: options,
          cacheOptions: cacheOptions ?? globalCacheOptions,
        ),
        cancelToken: cancelToken, // Pass token directly
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      // Convert DioException to a specific NetworkException
      throw _handleDioError(e);
    }
    // Catch other potential errors during request processing, though less common
    catch (e) {
      throw UnknownNetworkErrorException(
        message:
            'Unexpected error during GET request processing: $e', // $METHOD = GET/POST etc.
        code: NetworkErrorCode.unknownError, // Use specific code
        originalError: e,
      );
    }
  }

  /// Sends a POST request to the specified [url].
  ///
  /// - [url]: The request URL.
  /// - [data]: Optional request body data.
  /// - [queryParameters]: Optional URL query parameters.
  /// - [options]: Dio [Options] for this specific request. Merged with [cacheOptions].
  /// - [cancelToken]: Optional [CancelToken] for cancellation.
  /// - [onSendProgress]: Optional callback for tracking upload progress.
  /// - [onReceiveProgress]: Optional callback for tracking download progress.
  /// - [cacheOptions]: Optional [CacheOptions] specific to this request.
  ///                 Uses [globalCacheOptions] if null and available.
  ///
  /// Returns a [Future<Response>] containing the raw Dio response upon success.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CacheOptions? cacheOptions,
  }) async {
    try {
      final Response response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _mergeDioAndCacheOptions(
          dioOptions: options,
          cacheOptions: cacheOptions ?? globalCacheOptions,
        ),
        cancelToken: cancelToken, // Pass token directly
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownNetworkErrorException(
        message: 'Unexpected error during POST request processing: $e',
        code: NetworkErrorCode.unknownError, // Use specific code
        originalError: e,
      );
    }
  }

  /// Sends a PUT request to the specified [url].
  ///
  /// - [url]: The request URL.
  /// - [data]: Optional request body data.
  /// - [queryParameters]: Optional URL query parameters.
  /// - [options]: Dio [Options] for this specific request. Merged with [cacheOptions].
  /// - [cancelToken]: Optional [CancelToken] for cancellation.
  /// - [onSendProgress]: Optional callback for tracking upload progress.
  /// - [onReceiveProgress]: Optional callback for tracking download progress.
  /// - [cacheOptions]: Optional [CacheOptions] specific to this request.
  ///                 Uses [globalCacheOptions] if null and available.
  ///
  /// Returns a [Future<Response>] containing the raw Dio response upon success.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CacheOptions? cacheOptions,
  }) async {
    try {
      final Response response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _mergeDioAndCacheOptions(
          dioOptions: options,
          cacheOptions: cacheOptions ?? globalCacheOptions,
        ),
        cancelToken: cancelToken, // Pass token directly
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownNetworkErrorException(
        message: 'Unexpected error during PUT request processing: $e',
        code: NetworkErrorCode.unknownError, // Use specific code
        originalError: e,
      );
    }
  }

  /// Sends a DELETE request to the specified [url].
  ///
  /// - [url]: The request URL.
  /// - [data]: Optional request body data (less common for DELETE).
  /// - [queryParameters]: Optional URL query parameters.
  /// - [options]: Dio [Options] for this specific request. Merged with [cacheOptions].
  /// - [cancelToken]: Optional [CancelToken] for cancellation.
  /// - [cacheOptions]: Optional [CacheOptions] specific to this request.
  ///                 Uses [globalCacheOptions] if null and available.
  ///
  /// Returns a [Future<Response>] containing the raw Dio response upon success.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    CacheOptions? cacheOptions,
  }) async {
    try {
      final Response response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _mergeDioAndCacheOptions(
          dioOptions: options,
          cacheOptions: cacheOptions ?? globalCacheOptions,
        ),
        cancelToken: cancelToken, // Pass token directly
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownNetworkErrorException(
        message: 'Unexpected error during DELETE request processing: $e',
        code: NetworkErrorCode.unknownError, // Use specific code
        originalError: e,
      );
    }
  }

  /// Fetches raw data from the specified [url] as a list of bytes.
  ///
  /// Useful for retrieving images, files, or other non-JSON data.
  /// This method enforces `ResponseType.bytes`. Any `responseType` specified
  /// in the [options] parameter will be overridden.
  /// Supports caching via [cacheOptions] or [globalCacheOptions].
  ///
  /// - [url]: The request URL.
  /// - [queryParameters]: Optional URL query parameters.
  /// - [options]: Dio [Options] for this specific request (e.g., headers).
  ///            `responseType` will be forced to [ResponseType.bytes].
  /// - [cancelToken]: Optional [CancelToken] for cancellation.
  /// - [onReceiveProgress]: Optional callback for tracking download progress.
  /// - [cacheOptions]: Optional [CacheOptions] specific to this request.
  ///
  /// Returns a [Future<Response<List<int>>>] containing the raw byte data upon success.
  ///
  /// Throws a [NetworkException] subtype on failure.
  Future<Response<List<int>>> fetch(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    CacheOptions? cacheOptions,
  }) async {
    try {
      // Start with base options forcing bytes, then merge user options and cache options
      final mergedDioOptions = (options ?? Options()).copyWith(
        responseType: ResponseType.bytes,
      );

      final finalOptions = _mergeDioAndCacheOptions(
        dioOptions: mergedDioOptions, // Ensure ResponseType.bytes is kept
        cacheOptions: cacheOptions ?? globalCacheOptions,
      )?.copyWith(responseType: ResponseType.bytes); // Ensure again after merge

      final Response<List<int>> response = await _dio.get<List<int>>(
        // Specify type argument for clarity
        url,
        queryParameters: queryParameters,
        options: finalOptions, // Use the final merged options
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      // Handle potential DioException where response might not be List<int>
      // _handleDioError already handles the core network issues
      throw _handleDioError(e);
    } catch (e) {
      // Catch other unexpected errors
      throw UnknownNetworkErrorException(
        message: 'Unexpected error during fetch request processing: $e',
        code: NetworkErrorCode.unknownError,
        originalError: e,
      );
    }
  }

  /// Downloads a file from the specified [url] and saves it to [savePath].
  ///
  /// This method uses `Dio.download` internally. Caching is **not** supported
  /// or applied for download requests made via this method.
  ///
  /// - [url]: The file URL to download.
  /// - [savePath]: The absolute file path (including filename) where the file will be saved.
  ///               Ensure the directory exists and the app has write permissions.
  /// - [queryParameters]: Optional URL query parameters.
  /// - [options]: Dio [Options] for this specific request (e.g., headers). `responseType` is ignored.
  /// - [cancelToken]: Optional [CancelToken] for cancellation.
  /// - [onReceiveProgress]: **Strongly recommended** callback for tracking download progress (bytesReceived, totalBytes).
  /// - [deleteOnError]: If `true`, the partially downloaded file will be deleted if an error occurs. Defaults to `true`.
  ///
  /// Returns a standard [Future<Response>] upon successful download. The response body will typically be null.
  ///
  /// Throws a [NetworkException] subtype on network failures.
  /// Throws [UnknownNetworkErrorException] if a file system error occurs during saving
  /// (if not already wrapped in a DioException by Dio).
  Future<Response> download(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool deleteOnError = true,
  }) async {
    try {
      final response = await _dio.download(
        url,
        savePath, // The destination file path
        queryParameters: queryParameters,
        options: options, // Pass user options (like headers)
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        deleteOnError: deleteOnError,
      );
      return response;
    } on DioException catch (e) {
      // Handles network errors and potentially some file system errors if Dio wraps them
      throw _handleDioError(e);
    } catch (e) {
      // Catches potential file system errors (e.g., permissions, path not found)
      // if not wrapped by Dio, or other unexpected errors.
      throw UnknownNetworkErrorException(
        message:
            'Unexpected error during download request processing (check network, path, and permissions): $e',
        code: NetworkErrorCode
            .unknownError, // Could refine code if needed, but unknown is safe
        originalError: e,
      );
    }
  }

  /// Internal helper to merge Dio [Options] with [CacheOptions].
  ///
  /// Combines the `extra` field of Dio options with the cache options map.
  /// Returns null if both inputs are null.
  Options? _mergeDioAndCacheOptions({
    Options? dioOptions,
    CacheOptions? cacheOptions,
  }) {
    if (dioOptions == null && cacheOptions == null) {
      return null;
    } else if (dioOptions == null && cacheOptions != null) {
      // If only cache options exist, convert them to Dio Options
      return cacheOptions.toOptions();
    } else if (dioOptions != null && cacheOptions == null) {
      // If only Dio options exist, return them directly
      return dioOptions;
    } else {
      // Both exist, merge them
      final cacheOptionsMap = cacheOptions!.toExtra();
      final options = dioOptions!.copyWith(
        // Combine extras, prioritizing Dio's existing extras
        // if keys clash, though cache option keys are usually specific.
        extra: <String, dynamic>{
          ...cacheOptionsMap, // Cache options first
          ...?dioOptions.extra, // Dio options override if keys are the same
        },
      );
      return options;
    }
  }

  /// Converts a [DioException] into a more specific [NetworkException].
  ///
  /// This centralizes the error handling logic based on the [DioExceptionType].
  ///
  /// - [err]: The [DioException] caught during the request.
  ///
  /// Returns a corresponding [NetworkException] subtype.
  NetworkException _handleDioError(DioException err) {
    // Log the original error for debugging purposes, if needed
    // print('DioException encountered: ${err.type} - ${err.message}');
    // print('Error details: ${err.error}');
    // print('Response data: ${err.response?.data}');

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Usa il costruttore che assegna il codice
        return NetworkTimeoutException(
          'Request timed out (${err.type}).',
        ); // Messaggio di debug

      case DioExceptionType.badResponse:
        // Delegate to a factory that can extract status code and potentially response data
        // Assuming NetworkResponseException.fromDioException is implemented as discussed
        return NetworkResponseException.fromDioException(err);

      case DioExceptionType.cancel:
        return const NetworkCancelException();

      case DioExceptionType.unknown:
        // Potrebbe essere DNS, host non trovato etc.
        return NetworkConnectionException(
          message:
              'Connection failed (Unknown Dio Error): ${err.message ?? err.error ?? 'No specific message'}',
          code: NetworkErrorCode.networkUnreachable, // Codice appropriato
        );

      case DioExceptionType.badCertificate:
        return const NetworkSSLException();

      case DioExceptionType.connectionError:
        // Errore di connessione più specifico (es. rifiutata)
        return NetworkConnectionException(
          message:
              'Connection Error: ${err.message ?? err.error ?? 'No specific message'}',
          // Potresti voler differenziare qui, ma connectionRefused è un buon default
          code: NetworkErrorCode.connectionRefused,
        );
    }
  }
}
