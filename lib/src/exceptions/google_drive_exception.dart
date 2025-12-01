/// Base exception for Google Drive operations
class GoogleDriveException implements Exception {
  final String message;
  final int? statusCode;

  const GoogleDriveException(this.message, [this.statusCode]);

  @override
  String toString() => 'GoogleDriveException: $message';
}

/// Exception thrown when authentication fails
class AuthenticationException extends GoogleDriveException {
  const AuthenticationException(super.message);
}

/// Exception thrown when a file operation fails
class FileOperationException extends GoogleDriveException {
  const FileOperationException(super.message, [super.statusCode]);
}

/// Exception thrown when a file is not found
class FileNotFoundException extends GoogleDriveException {
  const FileNotFoundException(String message) : super(message, 404);
}

/// Exception thrown when upload fails
class UploadException extends GoogleDriveException {
  const UploadException(super.message, [super.statusCode]);
}

/// Exception thrown when download fails
class DownloadException extends GoogleDriveException {
  const DownloadException(super.message, [super.statusCode]);
}
