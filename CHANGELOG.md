# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added

- Initial release of Network Module
- Abstract `DioClient` base class for standardized API clients
- Comprehensive HTTP methods: `get`, `post`, `put`, `delete`, `fetch`, `download`
- Structured error handling with `NetworkException` hierarchy
- Stable error codes (`NetworkErrorCode` enum) for localization support
- Seamless integration with `dio_cache_interceptor` for caching
- Request cancellation support using Dio's `CancelToken`
- Progress tracking callbacks for upload/download operations
- Dependency injection friendly design
- Comprehensive test suite with 1594+ test lines
- Full documentation with usage examples
- Support for global and per-request cache options
- Automatic `DioException` to `NetworkException` conversion
- Support for custom interceptors and HTTP client adapters

### Features

- **Error Handling**: 6 specific exception types with localization-ready error codes
- **Caching**: Both global and per-request caching with `dio_cache_interceptor`
- **Testing**: Fully mockable design with comprehensive test coverage
- **Flexibility**: Abstract base class allows easy extension and customization
- **Production Ready**: Robust error handling and comprehensive documentation

### Dependencies

- `dio`: ^5.8.0 - HTTP client for Dart
- `dio_cache_interceptor`: ^4.0.0 - Caching support for Dio

### Development Dependencies

- `flutter_test`: SDK test framework
- `flutter_lints`: ^5.0.0 - Linting rules
- `mocktail`: ^1.0.4 - Mocking library for testing
