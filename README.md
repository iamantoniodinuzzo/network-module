# Network Module
[![codecov](https://codecov.io/gh/iamantoniodinuzzo/network-module/branch/main/graph/badge.svg)](https://codecov.io/gh/iamantoniodinuzzo/network-module)

A robust, reusable, and testable network layer package for Flutter applications, built on top of the powerful `dio` package. It provides a standardized way to handle network requests, error management, caching integration, and cancellation.

## Features

* **Standardized API Client:** Abstract `DioClient` base class for creating consistent API clients.
* **Common HTTP Methods:** Provides `get`, `post`, `put`, `delete` methods.
* **Specialized Methods:** Includes `fetch` (for raw byte data) and `download` (for saving files).
* **Structured Error Handling:** Automatically converts `DioException`s into a hierarchy of specific `NetworkException`s (`NetworkTimeoutException`, `NetworkResponseException`, `NetworkConnectionException`, etc.).
* **Error Codes for Localization:** Each `NetworkException` includes a stable `NetworkErrorCode` enum, making it easy to map errors to user-friendly, localized messages.
* **Caching Integration:** Seamlessly integrates with `dio_cache_interceptor` via global or per-request `CacheOptions`.
* **Request Cancellation:** Supports request cancellation using Dio's `CancelToken`.
* **Dependency Injection Friendly:** Designed to work well with dependency injection for easy testing and configuration.
* **Testable:** Easily mockable for unit testing.

## Installation

Add the package to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  network_module: # Replace with your actual package name if published
    # path: ../path/to/network_module # Or use git/hosted source
  dio: ^5.x.x # Ensure compatibility
  dio_cache_interceptor: ^3.x.x # Ensure compatibility
  # Add other necessary dependencies if any
```

Then run `flutter pub get`.

## Getting Started

1. **Create a Concrete Client:** Since `DioClient` is abstract, you need to create your own implementation:

    ```dart
    import 'package:network_module/network_module.dart';
    import 'package:dio/dio.dart';

    class ApiClient extends DioClient {
      ApiClient({required Dio dioClient, CacheOptions? globalCacheOptions})
          : super(
              dioClient: dioClient,
              globalCacheOptions: globalCacheOptions,
              // Optionally add base interceptors specific to this client here
            );

      // You can add specific methods here that call the base methods
      // e.g., Future<MyUserModel> getUser(String id) async { ... }
    }
    ```

2. **Configure Dio and Interceptors:** Create and configure a Dio instance. **This is the most crucial step** for adding essential cross-cutting logic via interceptors like logging, retries, caching, and authentication.

    ```dart
    import 'package:dio/dio.dart';
    import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
    import 'package:dio_smart_retry/dio_smart_retry.dart';
    // Import your custom Authentication Interceptor (see below)
    // import 'interceptors/auth_interceptor.dart';

    // --- 1. Configure Dependencies (Cache Store, Auth Logic) ---
    // Example Cache Store
    final cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 524288);
    final defaultCacheOptions = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
    );
    // Example Auth Logic Placeholder (replace with your actual implementation)
    // final authRepository = YourAuthenticationRepository();

    // --- 2. Create Dio Instance ---
    final dio = Dio(BaseOptions(
      baseUrl: '<https://api.yourapp.com/v1>',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json', // Default Content-Type
      },
    ));

    // --- 3. Add Interceptors (ORDER MATTERS!) ---
    dio.interceptors.addAll([
      // a) Retry Interceptor (Handles transient errors)
      RetryInterceptor(
        dio: dio,
        logPrint: print, // Optional
        retries: 3,
        retryDelays: const [ Duration(seconds: 1), Duration(seconds: 3), Duration(seconds: 5) ],
        retryableExtraStatuses: { NetworkErrorCode.serverError }, // Example: retry on 5xx
      ),

      // b) Cache Interceptor (Reads from/writes to cache)
      DioCacheInterceptor(options: defaultCacheOptions),

      // c) Custom Authentication Interceptor (Handles token injection & refresh)
      // AuthInterceptor(dio: dio, authRepository: authRepository), // Uncomment and use your implementation

      // d) Logging Interceptor (Logs request/response details - usually last)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: print, // Or use a dedicated logger
        // Consider enabling only in debug mode
      ),
    ]);

    // --- 4. Instantiate Your Client ---
    final apiClient = ApiClient(dioClient: dio);
    ```

3. **Make Requests:** Use the client methods within a `try-catch` block.

    ```dart
    Future<void> fetchSomeData() async {
      try {
        final response = await apiClient.get('/users/1');
        // Process successful response (response.data)
        print('User data: ${response.data}');
      } on NetworkException catch (e) {
        // Handle network errors using the exception code
        handleNetworkError(e);
      } catch (e) {
        // Handle other potential non-network errors
        print('An unexpected error occurred: $e');
      }
    }

    void handleNetworkError(NetworkException exception) {
      print('Network Error Code: ${exception.code}'); // Use this for localization!
      print('Message: ${exception.message}'); // Default English message/fallback
      if (exception is NetworkResponseException) {
        print('Status Code: ${exception.statusCode}');
        print('Response Data (if any): ${exception.responseData}');
      }
      // Show user-friendly message based on exception.code using your localization setup
      // showUserMessage(getLocalizedErrorMessage(exception.code));
    }
    ```
## Recommended Interceptors (Add to Dio)

While `DioClient` handles the core request and final error mapping, **Dio Interceptors** are essential for managing concerns like logging, retries, caching, and authentication. These should be added to your `Dio` instance *before* passing it to `DioClient`.

### 1. Logging (`LogInterceptor`)

* **Purpose:** Logs request and response details (URL, headers, body, status, timing). Crucial for debugging.
* **Provided by:** `dio` package.
* **Recommendation:** Add it, especially during development. Often placed last in the interceptor chain to log the final request/response. Consider enabling it conditionally based on build mode.

### 2. Retries (`dio_smart_retry` or Custom)

* **Purpose:** Automatically retries requests that fail due to transient network issues (e.g., timeouts, 5xx errors) or specific status codes.
* **Provided by:** Packages like `dio_smart_retry` or custom implementation.
* **Recommendation:** **Strongly recommended** for improving application resilience. Add it **early** in the interceptor chain so retries happen before other logic like caching potentially outdated error responses.

### 3. Caching (`DioCacheInterceptor`)

* **Purpose:** Implements HTTP caching based on `CacheOptions`. Reads from and writes to a specified cache store.
* **Provided by:** `dio_cache_interceptor` package.
* **Recommendation:** **Essential** if you intend to use the caching features supported by `DioClient`. Place it after the Retry interceptor (to potentially cache successful retried responses) but before Authentication (as you might want to serve cached data even if the user is temporarily unauthenticated).

### 4. Authentication (Custom)

* **Purpose:**
  * Injects authentication tokens (e.g., JWT Bearer token) into request headers.
  * Handles automatic token refresh when the access token expires (typically by catching 401 errors).
* **Provided by:** Requires a **custom implementation** tailored to your app's specific authentication flow (token storage, refresh endpoint, logout logic).
* **Recommendation:** **Essential** for most logged-in applications. This is often the most complex interceptor. It typically needs to:
  * Add the token in `onRequest`.
  * Catch 401s in `onError`.
  * Lock Dio, attempt refresh, update token, unlock Dio, and retry the original request.
  * Handle refresh failures (e.g., trigger logout).
  * Place it *after* caching (don't need auth for cached data) but *before* logging (log the request with the auth header).

### Interceptor Order (Crucial!)

The order in which you add interceptors to `dio.interceptors` matters significantly. A generally recommended order is:

1. **Retry Interceptor:** Handles transient network failures first.
2. **Cache Interceptor:** Checks cache before proceeding. If hit, avoids network call and subsequent interceptors.
3. **Authentication Interceptor:** Manages token injection and refresh logic *after* cache check but *before* the final request is logged or sent.
4. **Logging Interceptor:** Logs the final state of the request (with auth headers) and the response received (after potential retries/cache).

*Consult the documentation of specific interceptor packages for any specific ordering requirements they might have.*

## Core Methods

All methods handle errors by throwing a subtype of `NetworkException`.

### `get()`

Sends a GET request.

```dart
Future<Response> get(
  String url, {
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress, // Usually not needed for GET
  CacheOptions? cacheOptions, // Per-request cache override
})
```

**Example:**

```dart
final response = await apiClient.get(
  '/posts',
  queryParameters: {'userId': 1},
  cacheOptions: CacheOptions(policy: CachePolicy.refresh), // Force refresh
);
```

### `post()`

Sends a POST request.

```dart
Future<Response> post(
  String url, {
  dynamic data, // Request body
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
  CacheOptions? cacheOptions, // Caching POST results (use with caution)
})
```

**Example:**

```dart
final response = await apiClient.post(
  '/posts',
  data: {'title': 'foo', 'body': 'bar', 'userId': 1},
);
```

### `put()`

Sends a PUT request.

```dart
Future<Response> put(
  String url, {
  dynamic data, // Request body
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
  CacheOptions? cacheOptions, // Caching PUT results (use with caution)
})
```

**Example:**

```dart
final response = await apiClient.put(
  '/posts/1',
  data: {'id': 1, 'title': 'foo_updated', 'body': 'bar', 'userId': 1},
);
```

### `delete()`

Sends a DELETE request.

```dart
Future<Response> delete(
  String url, {
  dynamic data, // Less common for DELETE
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  CacheOptions? cacheOptions, // Usually for invalidating cache
})
```

**Example:**

```dart
final response = await apiClient.delete('/posts/1');
// Check response.statusCode == 200 or 204
```

### `fetch()`

Fetches raw data (e.g., images, files) as bytes. Enforces `ResponseType.bytes`. Supports caching.

```dart
Future<Response<List<int>>> fetch(
  String url, {
  Map<String, dynamic>? queryParameters,
  Options? options, // responseType is overridden
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
  CacheOptions? cacheOptions,
})
```

**Example:**

```dart
final response = await apiClient.fetch('/images/logo.png');
final List<int> imageBytes = response.data;
// Use imageBytes with Image.memory(...)
```

### `download()`

Downloads a file to a specified path. **Does not support caching**.

```dart
Future<Response> download(
  String url,
  String savePath, { // Absolute path to save the file
  Map<String, dynamic>? queryParameters,
  Options? options, // e.g., for headers
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress, // Highly recommended for UX
  bool deleteOnError = true,
})
```

**Example:**

```dart
// Get temp directory (using path_provider package)
final tempDir = await getTemporaryDirectory();
final filePath = '${tempDir.path}/my_downloaded_file.zip';

final response = await apiClient.download(
  '/files/archive.zip',
  filePath,
  onReceiveProgress: (received, total) {
    if (total != -1) {
      print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
    }
  },
);
// Check response.statusCode == 200 for success
```

## Error Handling & Localization

The client catches `DioException` and throws specific `NetworkException` subtypes:

* `NetworkTimeoutException`: Request timed out.
* `NetworkResponseException`: Server returned an error status code (4xx, 5xx). Contains `statusCode` and `responseData`.
* `NetworkCancelException`: Request was cancelled via `CancelToken`.
* `NetworkConnectionException`: Failed to connect (DNS, connection refused, etc.).
* `NetworkSSLException`: SSL certificate issue.
* `UnknownNetworkErrorException`: Unexpected error during processing or unhandled Dio error. Contains `originalError`.

**Using `NetworkErrorCode` for Localization:**

Each `NetworkException` has a `code` property of type `NetworkErrorCode` (enum). Use this code as a stable key to retrieve localized error messages for the user.

```dart
// Example using flutter_localizations (AppLocalizations l10n)

void handleNetworkError(NetworkException exception, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  String userMessage;

  switch (exception.code) {
    case NetworkErrorCode.connectionTimeout:
      userMessage = l10n.errorNetworkTimeout;
      break;
    case NetworkErrorCode.unauthorized:
      userMessage = l10n.errorNetworkUnauthorized;
      // Maybe trigger logout action
      break;
    case NetworkErrorCode.notFound:
      userMessage = l10n.errorNetworkNotFound;
      break;
    case NetworkErrorCode.serverError:
       userMessage = l10n.errorNetworkServer;
       break;
    case NetworkErrorCode.connectionRefused:
    case NetworkErrorCode.networkUnreachable:
       userMessage = l10n.errorNetworkConnection;
       break;
    // ... handle all other NetworkErrorCode cases ...
    default:
      userMessage = l10n.errorNetworkUnknown; // Generic fallback
      // Log the specific exception details for debugging
      print('Unhandled Network Error Code: ${exception.code}, Msg: ${exception.message}');
      if(exception is UnknownNetworkErrorException) {
        print('Original Error: ${exception.originalError}');
      }
  }

  // Show the userMessage in a Snackbar, Dialog, etc.
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userMessage)));
}

// --- In your .arb file ---
// "errorNetworkTimeout": "Request timed out. Please check your connection.",
// "errorNetworkUnauthorized": "Authentication failed. Please log in again.",
// ... etc ...
```

## Caching

Caching relies on `dio_cache_interceptor`.

* **Global:** Configure `CacheOptions` when creating the `DioCacheInterceptor` and adding it to your `Dio` instance.
* **Per-Request:** Pass a `CacheOptions` object to the `cacheOptions` parameter of `get`, `post`, `put`, `delete`, or `fetch` to override global settings for that specific request.
* **`download()`:** This method **does not** use caching.

```dart
// Force refresh for this specific request
await apiClient.get('/users/me', cacheOptions: CacheOptions(policy: CachePolicy.refresh));

// Try to get from cache first, then request if expired (standard policy)
await apiClient.get('/products');
```

## Cancellation

Create a `CancelToken` and pass it to the desired request method. Call `cancel()` on the token to abort the request.

```dart
final cancelToken = CancelToken();

// Start request
final futureResponse = apiClient.get(
  '/long_running_operation',
  cancelToken: cancelToken,
);

// If the user navigates away or presses a cancel button:
if (!cancelToken.isCancelled) {
  cancelToken.cancel('Request cancelled by user.');
}

try {
  final response = await futureResponse;
  // Process response if not cancelled
} on NetworkCancelException {
  print('Request was successfully cancelled.');
} on NetworkException catch(e) {
  // Handle other network errors
}
```

## Retry Logic

This client **does not** include built-in retry logic. It's recommended to add this via a dedicated `Interceptor` when configuring your main `Dio` instance.

**Example using `dio_smart_retry` (add package to pubspec.yaml):**

```dart
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

final dio = Dio(BaseOptions(/* ... */));

// Add the RetryInterceptor BEFORE other interceptors that might depend on the final response
dio.interceptors.add(RetryInterceptor(
  dio: dio,
  logPrint: print, // Log retry attempts
  retries: 3, // Number of retries
  retryDelays: const [
    Duration(seconds: 1), // Wait 1 sec before first retry
    Duration(seconds: 3), // Wait 3 sec before second retry
    Duration(seconds: 5), // Wait 5 sec before third retry
  ],
  retryableExtraStatuses: {status401Unauthorized}, // Example: Retry on 401
));

// Add other interceptors (Cache, Log, Auth, etc.)
// ...

// Inject this Dio instance into your ApiClient
final apiClient = ApiClient(dioClient: dio);
```

## Advanced Configuration

You can pass custom `Interceptors` or a custom `HttpClientAdapter` when creating your concrete `DioClient` instance if needed, although most configuration should happen on the `Dio` instance itself.

```dart
final customInterceptor = MyCustomInterceptor();
final customAdapter = MyCustomAdapter();

final apiClient = ApiClient(
  dioClient: dio,
  interceptors: [customInterceptor], // Added ONLY to this client instance's Dio
  httpClientAdapter: customAdapter,  // Replaces Dio's adapter for this instance
);
```

## Testing

The use of dependency injection (passing the `Dio` instance) makes `DioClient` highly testable. Use a mocking framework like `mocktail` or `mockito` to mock the `Dio` instance and verify interactions or simulate responses/errors. Refer to the `test/dio_client_test.dart` file in this package for detailed examples.
