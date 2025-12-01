import 'drive_file.dart';

/// Result of a file upload operation
class UploadResult {
  final DriveFile file;
  final bool success;
  final String? error;

  const UploadResult({
    required this.file,
    required this.success,
    this.error,
  });

  factory UploadResult.success(DriveFile file) {
    return UploadResult(file: file, success: true);
  }

  factory UploadResult.failure(String error) {
    return UploadResult(
      file: const DriveFile(id: '', name: ''),
      success: false,
      error: error,
    );
  }
}
