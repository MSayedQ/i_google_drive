import 'package:flutter_test/flutter_test.dart';
import 'package:i_google_drive/i_google_drive.dart';

void main() {
  test('package exports are available', () {
    // Test that all main exports are accessible
    expect(GoogleDriveService, isNotNull);
    expect(DriveFile, isNotNull);
    expect(UploadResult, isNotNull);
    expect(GoogleDriveException, isNotNull);
    expect(AuthenticationException, isNotNull);
    expect(FileOperationException, isNotNull);
    expect(FileNotFoundException, isNotNull);
    expect(UploadException, isNotNull);
    expect(DownloadException, isNotNull);
  });

  test('GoogleDriveService can be instantiated', () {
    final service = GoogleDriveService();
    expect(service, isNotNull);
    expect(service, isA<GoogleDriveService>());
  });

  test('GoogleDriveService can be instantiated with custom scopes', () {
    final service = GoogleDriveService(
      scopes: [
        'https://www.googleapis.com/auth/drive.file',
      ],
    );
    expect(service, isNotNull);
    expect(service, isA<GoogleDriveService>());
  });
}
