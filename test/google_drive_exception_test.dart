import 'package:flutter_test/flutter_test.dart';
import 'package:i_google_drive/i_google_drive.dart';

void main() {
  group('GoogleDriveException', () {
    test('should create GoogleDriveException with message', () {
      const exception = GoogleDriveException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), 'GoogleDriveException: Test error');
    });

    test('should create GoogleDriveException with message and status code', () {
      const exception = GoogleDriveException('Test error', 404);

      expect(exception.message, 'Test error');
      expect(exception.statusCode, 404);
      expect(exception.toString(), 'GoogleDriveException: Test error');
    });
  });

  group('AuthenticationException', () {
    test('should create AuthenticationException', () {
      const exception = AuthenticationException('Auth failed');

      expect(exception.message, 'Auth failed');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), 'GoogleDriveException: Auth failed');
    });

    test('should be instance of GoogleDriveException', () {
      const exception = AuthenticationException('Auth failed');

      expect(exception, isA<GoogleDriveException>());
    });
  });

  group('FileOperationException', () {
    test('should create FileOperationException with message', () {
      const exception = FileOperationException('Operation failed');

      expect(exception.message, 'Operation failed');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), 'GoogleDriveException: Operation failed');
    });

    test('should create FileOperationException with message and status code', () {
      const exception = FileOperationException('Operation failed', 500);

      expect(exception.message, 'Operation failed');
      expect(exception.statusCode, 500);
      expect(exception.toString(), 'GoogleDriveException: Operation failed');
    });

    test('should be instance of GoogleDriveException', () {
      const exception = FileOperationException('Operation failed');

      expect(exception, isA<GoogleDriveException>());
    });
  });

  group('FileNotFoundException', () {
    test('should create FileNotFoundException', () {
      const exception = FileNotFoundException('File not found');

      expect(exception.message, 'File not found');
      expect(exception.statusCode, 404);
      expect(exception.toString(), 'GoogleDriveException: File not found');
    });

    test('should be instance of GoogleDriveException', () {
      const exception = FileNotFoundException('File not found');

      expect(exception, isA<GoogleDriveException>());
    });
  });

  group('UploadException', () {
    test('should create UploadException with message', () {
      const exception = UploadException('Upload failed');

      expect(exception.message, 'Upload failed');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), 'GoogleDriveException: Upload failed');
    });

    test('should create UploadException with message and status code', () {
      const exception = UploadException('Upload failed', 400);

      expect(exception.message, 'Upload failed');
      expect(exception.statusCode, 400);
      expect(exception.toString(), 'GoogleDriveException: Upload failed');
    });

    test('should be instance of GoogleDriveException', () {
      const exception = UploadException('Upload failed');

      expect(exception, isA<GoogleDriveException>());
    });
  });

  group('DownloadException', () {
    test('should create DownloadException with message', () {
      const exception = DownloadException('Download failed');

      expect(exception.message, 'Download failed');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), 'GoogleDriveException: Download failed');
    });

    test('should create DownloadException with message and status code', () {
      const exception = DownloadException('Download failed', 500);

      expect(exception.message, 'Download failed');
      expect(exception.statusCode, 500);
      expect(exception.toString(), 'GoogleDriveException: Download failed');
    });

    test('should be instance of GoogleDriveException', () {
      const exception = DownloadException('Download failed');

      expect(exception, isA<GoogleDriveException>());
    });
  });
}

