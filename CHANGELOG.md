# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-30

### Added
- Initial release of i_google_drive package
- Google Sign-In authentication support
- Upload files to Google Drive
- Download files from Google Drive
- List files with filtering and search
- Get file by ID or name
- Delete files from Google Drive
- Create folders in Google Drive
- Overwrite existing files option
- Comprehensive error handling with specific exception types
- Automatic token refresh
- Support for Google Workspace files (exported as PDF)
- Custom scopes support
- Full example app demonstrating all features

### Features
- `GoogleDriveService` class with complete API
- `DriveFile` model for file information
- `UploadResult` model for upload operations
- Exception classes: `AuthenticationException`, `FileOperationException`, `FileNotFoundException`, `UploadException`, `DownloadException`

