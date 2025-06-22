# 🤝 Contributing to Network Module

Thank you for your interest in contributing to the Network Module! We welcome contributions from the community and are pleased to have you join us.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Release Process](#release-process)

## 📜 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.13.0 or higher)
- Dart SDK (3.0.0 or higher)
- Git

### Development Setup

1. **Fork the repository**

   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/network-module.git
   cd network-module
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   cd example
   flutter pub get
   cd ..
   ```

3. **Verify setup**

   ```bash
   # Run tests to ensure everything works
   flutter test
   
   # Run analysis
   flutter analyze
   
   # Build example app
   cd example
   flutter build apk --debug
   ```

## 🛠️ How to Contribute

### 🐛 Reporting Bugs

1. Check existing issues to avoid duplicates
2. Use the bug report template
3. Provide minimal reproduction steps
4. Include relevant system information

### ✨ Suggesting Features

1. Check existing feature requests
2. Use the feature request template
3. Explain the use case and problem it solves
4. Consider the scope and alignment with project goals

### 💻 Code Contributions

#### 🔄 Git Flow Workflow

**We use Git Flow for our development process. Please follow these branch conventions:**

- **`main`**: Production-ready code, only accepts merges from `release` and `hotfix` branches
- **`develop`**: Integration branch for features, main development branch  
- **`feature/*`**: New features (branch from `develop`, merge back to `develop`)
- **`release/*`**: Release preparation (branch from `develop`, merge to `main` and `develop`)
- **`hotfix/*`**: Critical fixes (branch from `main`, merge to `main` and `develop`)

#### Development Steps

1. **Find an issue to work on**
   - Look for issues labeled `good first issue` for beginners
   - Comment on the issue to let others know you're working on it

2. **Create appropriate branch following Git Flow**

   #### Using Standard Git Commands

   ```bash
   # For new features (from develop)
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   
   # For hotfixes (from main)
   git checkout main
   git pull origin main
   git checkout -b hotfix/your-hotfix-name
   
   # For releases (from develop)
   git checkout develop
   git pull origin develop
   git checkout -b release/1.2.0
   ```

   #### Using Git Flow Extension (optional)

   The repository includes a `.gitflow` configuration file with our preferred settings.

   ```bash
   # Initialize Git Flow (one time setup) - uses .gitflow config
   git flow init -d
   
   # Start a new feature
   git flow feature start your-feature-name
   
   # Finish a feature (merges to develop)
   git flow feature finish your-feature-name
   
   # Start a hotfix
   git flow hotfix start your-hotfix-name
   
   # Finish a hotfix (merges to main and develop)
   git flow hotfix finish your-hotfix-name
   
   # Start a release
   git flow release start 1.2.0
   
   # Finish a release (merges to main and develop, tags)
   git flow release finish 1.2.0
   ```

3. **Make your changes**
   - Follow the coding standards
   - Add tests for new functionality
   - Update documentation if needed

4. **Test your changes**

   ```bash
   # Run all tests
   flutter test
   
   # Run with coverage
   flutter test --coverage
   
   # Analyze code
   flutter analyze
   
   # Format code
   dart format .
   ```

5. **Commit your changes following Conventional Commits**

   ```bash
   git add .
   git commit -m "feat: add new feature description"
   # or
   git commit -m "fix: resolve issue with error handling"
   ```

6. **Push and create PR to appropriate branch**

   #### Using Standard Git Commands

   ```bash
   # Push your branch
   git push origin your-branch-name
   
   # Create PR targeting:
   # - develop (for features and releases)
   # - main (for hotfixes)
   ```

   #### Using Git Flow Extension

   ```bash
   # Git Flow handles merging automatically
   # Just push if you need backup/collaboration during development
   git push origin feature/your-feature-name
   
   # When ready, finish the feature (no PR needed)
   git flow feature finish your-feature-name
   ```

   **Note**: When using Git Flow extension, features are merged directly to develop. For code review, you can still create PRs manually or use the standard Git commands approach.

#### Branch Protection Rules

- `main` and `develop` are protected branches
- All changes must go through Pull Requests
- CI/CD checks must pass before merging
- At least one maintainer approval required

## 🔄 Pull Request Process

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (for user-facing changes)
- [ ] No breaking changes (or properly documented)

### PR Requirements

1. **Use the PR template**
2. **Provide clear description** of changes
3. **Link related issues** using keywords (Fixes #123)
4. **Add appropriate labels**
5. **Request review** from maintainers

### Review Process

1. **Automated checks** must pass (CI/CD runs only on `main` and `develop`)
2. **Code review** by maintainers
3. **Address feedback** promptly
4. **Approval** from at least one maintainer
5. **Merge** by maintainers following Git Flow:
   - Features merge into `develop`
   - Hotfixes merge into `main` (and then into `develop`)
   - Releases merge from `develop` to `main`

## 📏 Coding Standards

### Dart/Flutter Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` for consistent formatting
- Follow `flutter analyze` recommendations

### Code Organization

```
lib/
├── dio_client.dart          # Main client implementation
├── network_exception.dart   # Exception hierarchy
└── network_module.dart      # Public exports

test/
├── dio_client_test.dart     # Client tests
└── network_exception_test.dart # Exception tests
```

### Naming Conventions

- **Classes**: PascalCase (`DioClient`)
- **Methods/Variables**: camelCase (`getData`)
- **Constants**: lowerCamelCase (`defaultTimeout`)
- **Files**: snake_case (`dio_client.dart`)

### Documentation

- Use DartDoc comments for public APIs
- Include examples in complex methods
- Document parameters and return values
- Explain exceptions that can be thrown

```dart
/// Performs a GET request to the specified [url].
///
/// Returns a [Response] containing the server response data.
/// Throws [NetworkException] on network or server errors.
///
/// Example:
/// ```dart
/// final response = await client.get('/api/users');
/// print(response.data);
/// ```
Future<Response> get(String url) async {
  // Implementation
}
```

## 🧪 Testing Guidelines

### Test Structure

- **Unit tests**: Test individual methods and classes
- **Integration tests**: Test component interactions
- **Example tests**: Ensure example app works

### Test Requirements

- **100% coverage** for new code
- **Meaningful test names** describing what they test
- **Test edge cases** and error conditions
- **Mock external dependencies** (HTTP calls, etc.)

### Test Example

```dart
group('DioClient', () {
  late MockDio mockDio;
  late TestDioClient client;

  setUp(() {
    mockDio = MockDio();
    client = TestDioClient(dioClient: mockDio);
  });

  test('should return response on successful GET request', () async {
    // Arrange
    when(() => mockDio.get(any())).thenAnswer(
      (_) async => Response(data: 'success'),
    );

    // Act
    final response = await client.get('/test');

    // Assert
    expect(response.data, 'success');
    verify(() => mockDio.get('/test')).called(1);
  });
});
```

## 📚 Documentation

### Types of Documentation

1. **API Documentation**: Generated from DartDoc comments
2. **README.md**: Package overview and quick start
3. **Example App**: Practical usage demonstration
4. **CHANGELOG.md**: Version history and changes

### Documentation Standards

- **Clear and concise** explanations
- **Working code examples**
- **Step-by-step instructions**
- **Screenshots** where helpful
- **Keep it updated** with code changes

## 🚀 Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Steps

1. **Update version** in `pubspec.yaml`
2. **Update CHANGELOG.md** with changes
3. **Create release tag** (`v1.0.0`)
4. **GitHub Actions** handles pub.dev publishing
5. **Create GitHub release** with notes

### Pre-release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped correctly
- [ ] Example app works
- [ ] Breaking changes documented

## 🆘 Getting Help

### Where to Ask

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Code Review**: PR comments and suggestions

### Response Times

- **Bug reports**: Within 48 hours
- **Feature requests**: Within 1 week
- **Pull requests**: Within 3-5 days

## 🏷️ Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `needs-triage`: Needs initial review
- `priority-high`: High priority issue

## 📞 Contact

- **Maintainer**: [Your Name]
- **Email**: [your.email@example.com]
- **GitHub**: [@yourusername]

---

Thank you for contributing to make the Network Module better! 🙏
