# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-06-22

### Added

- **Git Flow Integration**: Complete Git Flow workflow with standard commands and extension support
- **Streamlined CI/CD**: Simplified workflow structure with only essential validations
- **Security Enhancements**: Dedicated security scan workflow with monthly scheduled runs
- **Dependabot Configuration**: Monthly automatic dependency updates for Dart, Flutter, and GitHub Actions
- **Enhanced Documentation**: Comprehensive Git Flow guide in CONTRIBUTING.md and README.md
- **GitHub Release Integration**: Automatic GitHub Release creation with pub.dev publishing

### Changed

- **Workflow Structure**: Simplified from 7 workflows to 3 focused workflows
- **CI/CD Efficiency**: Single job workflows instead of complex multi-job pipelines
- **Flutter Versions**: Removed hardcoded versions, now uses stable channel
- **Build Process**: Removed unnecessary example app builds from CI workflows
- **Security Scanning**: Monthly security audits instead of weekly (first Monday of each month)
- **Dependency Updates**: Monthly Dependabot runs instead of weekly

### Removed

- **Complex Workflows**: Eliminated redundant and overly complex workflow files
- **Example App Builds**: Removed unnecessary Flutter app compilation from CI
- **Feature Branch Validation**: Simplified to main/develop validation only
- **Duplicate Workflows**: Consolidated multiple publish workflows into single solution

### Fixed

- **Security Scan**: Fixed "No active package pana" error with proper installation
- **Git Flow Configuration**: Added `.gitflow` configuration file for consistent setup
- **Workflow Maintenance**: Reduced maintenance overhead with streamlined structure
- **Coverage Files**: Added coverage files to .gitignore to prevent Git tracking issues

### Security

- **Monthly Security Scans**: Automated security audits on first Monday of each month
- **Dependency Monitoring**: Automated vulnerability detection with GitHub Dependency Review
- **Reduced Attack Surface**: Simplified workflows with fewer external dependencies

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
