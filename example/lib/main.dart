import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:network_module/network_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Network Module Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const NetworkExamplePage(),
      );
}

class NetworkExamplePage extends StatefulWidget {
  const NetworkExamplePage({super.key});

  @override
  State<NetworkExamplePage> createState() => _NetworkExamplePageState();
}

class _NetworkExamplePageState extends State<NetworkExamplePage> {
  late final ApiClient _apiClient;
  String _result = 'Tap a button to make a request';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeApiClient();
  }

  void _initializeApiClient() {
    // Configure cache store
    final cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 524288);
    final defaultCacheOptions = CacheOptions(
      store: cacheStore,
      maxStale: const Duration(days: 7),
    );

    // Create Dio instance
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      DioCacheInterceptor(options: defaultCacheOptions),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    ]);

    // Initialize API client
    _apiClient = ApiClient(
      dioClient: dio,
      globalCacheOptions: defaultCacheOptions,
    );
  }

  Future<void> _makeGetRequest() async {
    setState(() {
      _isLoading = true;
      _result = 'Loading...';
    });

    try {
      final response = await _apiClient.get('/posts/1');
      setState(() {
        _result = 'GET Success:\n${response.data}';
      });
    } on NetworkException catch (e) {
      setState(() {
        _result = 'Network Error: ${e.code}\nMessage: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _result = 'Unexpected Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePostRequest() async {
    setState(() {
      _isLoading = true;
      _result = 'Loading...';
    });

    try {
      final response = await _apiClient.post(
        '/posts',
        data: {
          'title': 'Network Module Example',
          'body': 'This is a test post from the network module example.',
          'userId': 1,
        },
      );
      setState(() {
        _result = 'POST Success:\n${response.data}';
      });
    } on NetworkException catch (e) {
      setState(() {
        _result = 'Network Error: ${e.code}\nMessage: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _result = 'Unexpected Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeErrorRequest() async {
    setState(() {
      _isLoading = true;
      _result = 'Loading...';
    });

    try {
      await _apiClient.get('/posts/999999'); // This should return 404
    } on NetworkResponseException catch (e) {
      setState(() {
        _result = 'Response Error Caught:\n'
            'Code: ${e.code}\n'
            'Status: ${e.statusCode}\n'
            'Message: ${e.message}';
      });
    } on NetworkException catch (e) {
      setState(() {
        _result = 'Network Error: ${e.code}\nMessage: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _result = 'Unexpected Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Network Module Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network Module Demo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This example demonstrates the Network Module features:',
                      ),
                      SizedBox(height: 8),
                      Text('• GET request with caching'),
                      Text('• POST request with data'),
                      Text('• Error handling with specific exceptions'),
                      Text('• Structured error codes for localization'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _makeGetRequest,
                child: const Text('Make GET Request'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _makePostRequest,
                child: const Text('Make POST Request'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _makeErrorRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Test Error Handling'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Result:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (_isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _result,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// Concrete implementation of DioClient
class ApiClient extends DioClient {
  ApiClient({
    required super.dioClient,
    super.globalCacheOptions,
    super.interceptors,
    super.httpClientAdapter,
  });

  // You can add specific methods here that call the base methods
  Future<Response> getUser(String id) async => get('/users/$id');

  Future<Response> createPost({
    required String title,
    required String body,
    required int userId,
  }) async =>
      post(
        '/posts',
        data: {
          'title': title,
          'body': body,
          'userId': userId,
        },
      );
}
