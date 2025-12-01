import 'package:flutter_test/flutter_test.dart';
import 'package:i_google_drive/i_google_drive.dart';

void main() {
  group('UploadResult', () {
    test('should create successful UploadResult', () {
      final file = const DriveFile(
        id: 'test-id',
        name: 'test-file.pdf',
      );

      final result = UploadResult.success(file);

      expect(result.success, isTrue);
      expect(result.file, file);
      expect(result.error, isNull);
    });

    test('should create failed UploadResult', () {
      const errorMessage = 'Upload failed';

      final result = UploadResult.failure(errorMessage);

      expect(result.success, isFalse);
      expect(result.error, errorMessage);
      expect(result.file.id, '');
      expect(result.file.name, '');
    });

    test('should create UploadResult with all properties', () {
      final file = const DriveFile(
        id: 'test-id',
        name: 'test-file.pdf',
      );

      var result = UploadResult(
        file: file,
        success: true,
        error: null,
      );

      expect(result.success, isTrue);
      expect(result.file, file);
      expect(result.error, isNull);
    });

    test('should create UploadResult with error', () {
      final file = const DriveFile(
        id: 'test-id',
        name: 'test-file.pdf',
      );

      var result = UploadResult(
        file: file,
        success: false,
        error: 'Upload failed',
      );

      expect(result.success, isFalse);
      expect(result.file, file);
      expect(result.error, 'Upload failed');
    });
  });
}
