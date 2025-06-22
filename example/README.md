# Network Module Example

This example demonstrates how to use the Network Module package in a Flutter application.

## Features Demonstrated

- **GET Requests**: Making GET requests with automatic caching
- **POST Requests**: Sending POST requests with data
- **Error Handling**: Comprehensive error handling with specific exception types
- **Caching**: Integration with dio_cache_interceptor for request caching
- **Logging**: Request and response logging for debugging

## Running the Example

1. Navigate to the example directory:

   ```bash
   cd example
   ```

2. Get dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

## What the Example Shows

The example app provides three buttons to demonstrate different Network Module features:

### 1. GET Request

- Makes a GET request to JSONPlaceholder API
- Demonstrates caching behavior
- Shows successful response handling

### 2. POST Request

- Creates a new post via JSONPlaceholder API
- Shows how to send data in request body
- Demonstrates successful creation response

### 3. Error Handling

- Intentionally makes a request that will fail (404)
- Shows how different NetworkException types are caught
- Demonstrates structured error codes for localization

## Code Structure

- `main.dart` - Complete example with UI and network calls
- `ApiClient` - Concrete implementation of DioClient
- Error handling examples for different scenarios
- Proper interceptor configuration (caching, logging)

## Key Concepts

1. **DioClient Extension**: How to extend the abstract DioClient class
2. **Interceptor Configuration**: Setting up caching and logging interceptors
3. **Error Handling**: Catching and handling different NetworkException types
4. **Structured Responses**: Working with API responses and error codes
