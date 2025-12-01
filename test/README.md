# Tests for i_google_drive

This directory contains tests for the `i_google_drive` package.

## Running Tests

### Run all tests

```bash
flutter test
```

### Run specific test file

```bash
flutter test test/drive_file_test.dart
```

### Run tests with coverage

```bash
flutter test --coverage
```

## Test Structure

### Unit Tests

- **drive_file_test.dart** - Tests for `DriveFile` model

  - JSON serialization/deserialization
  - Property handling
  - Edge cases

- **upload_result_test.dart** - Tests for `UploadResult` model

  - Success and failure cases
  - Factory methods

- **google_drive_exception_test.dart** - Tests for exception classes

  - All exception types
  - Message and status code handling

- **google_drive_service_test.dart** - Tests for `GoogleDriveService`

  - Authentication methods
  - File operations (with mocks)

- **widget_test.dart** - Basic package structure tests
  - Export verification
  - Service instantiation

## Generating Mocks

If you need to regenerate mocks for `google_drive_service_test.dart`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Test Coverage

The tests cover:

- ✅ Model serialization/deserialization
- ✅ Exception handling
- ✅ Authentication flow
- ✅ Error cases
- ✅ Edge cases

## Note

Some integration tests require actual Google Cloud credentials and are not included in the unit test suite. For full integration testing, use the example app with proper Google Cloud configuration.
