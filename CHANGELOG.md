# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-06-22

### Added

- **Git Flow Integration**: Complete Git Flow workflow with standard commands and extension support
- **Workflow Optimization**: Removed hardcoded Flutter versions, now uses stable channel
- **Security Enhancements**: Dedicated security scan workflow with scheduled runs
- **Dependabot Configuration**: Automatic dependency updates for Dart, Flutter, and GitHub Actions
- **Enhanced Documentation**: Comprehensive Git Flow guide in CONTRIBUTING.md and README.md
- **Feature Validation**: Lightweight validation workflow for feature branches
- **GitHub Release Integration**: Automatic GitHub Release creation with pub.dev publishing

### Changed

- **CI/CD Workflows**: Now run only on `main` and `develop` branches for efficiency
- **Flutter Versions**: Removed hardcoded versions, now uses `stable` and `beta` channels
- **Security Scanning**: Improved security audit with proper pana installation and error handling
- **Workflow Structure**: Consolidated duplicate workflows into single, comprehensive solutions

### Fixed

- **Security Scan**: Fixed "No active package pana" error with proper installation
- **Build Process**: Re-enabled build job with documentation generation
- **Git Flow Configuration**: Added `.gitflow` configuration file for consistent setup

### Security

- **Automated Security Scans**: Weekly security audits with detailed reporting
- **Dependency Monitoring**: Automated vulnerability detection with GitHub Dependency Review
- **Outdated Dependencies**: Regular checks for outdated packages

## [1.0.0]

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
