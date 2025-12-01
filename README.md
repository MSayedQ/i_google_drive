# i_google_drive

[![pub package](https://img.shields.io/pub/v/i_google_drive.svg)](https://pub.dev/packages/i_google_drive)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package for uploading, downloading, and managing files in Google Drive. This package provides a simple and easy-to-use API for interacting with Google Drive in your Flutter applications.

## Features

- ✅ **Upload files** to Google Drive with support for custom names and folders
- ✅ **Download files** from Google Drive with automatic MIME type handling
- ✅ **List files** with filtering, searching, and pagination support
- ✅ **Get file information** by ID or name
- ✅ **Delete files** from Google Drive
- ✅ **Create folders** with parent folder support
- ✅ **Google Sign-In integration** with automatic token management
- ✅ **Overwrite existing files** option
- ✅ **Comprehensive error handling** with specific exception types
- ✅ **Automatic token refresh** for seamless authentication
- ✅ **Support for Google Workspace files** (Docs, Sheets, Slides exported as PDF)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  i_google_drive: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Setup

### 1. Google Cloud Console Configuration

#### Step 1: Create a Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google Drive API**

#### Step 2: Configure OAuth Consent Screen

1. Navigate to **APIs & Services** → **OAuth consent screen**
2. Select **External** (for public apps) or **Internal** (for Google Workspace)
3. Fill in the required information:
   - App name
   - User support email
   - Developer contact information
4. Add scopes:
   - `https://www.googleapis.com/auth/drive.file`
   - `https://www.googleapis.com/auth/drive`
5. Add test users (if app is in Testing mode)

#### Step 3: Create OAuth Credentials

##### Android

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Select **Android** as application type
4. Get your SHA-1 certificate fingerprint:

```bash
# For debug keystore
keytool -keystore ~/.android/debug.keystore -list -v -alias androiddebugkey -storepass android -keypass android

# Or using Gradle
cd android
./gradlew signingReport
```

5. Add the SHA-1 fingerprint to your OAuth client
6. Set package name: `com.yourcompany.yourapp`

##### iOS

1. Create OAuth 2.0 credentials for iOS in Google Cloud Console
2. Download `GoogleService-Info.plist`
3. Add it to your Xcode project in the `ios/Runner/` directory
4. Update `ios/Runner/Info.plist` with your reversed client ID:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

### 2. Android Configuration

Ensure your `android/app/build.gradle` has the minimum SDK version:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for Google Sign-In
    }
}
```

### 3. iOS Configuration

No additional configuration needed beyond the OAuth setup above.

## Usage

### Basic Example

```dart
import 'package:i_google_drive/i_google_drive.dart';
import 'dart:io';

void main() async {
  // Create an instance of GoogleDriveService
  final driveService = GoogleDriveService();

  // Sign in the user
  try {
    await driveService.signIn();
    print('Signed in successfully!');
  } catch (e) {
    print('Sign in failed: $e');
    return;
  }

  // Upload a file
  final file = File('/path/to/your/file.pdf');
  final uploadResult = await driveService.uploadFile(
    file,
    fileName: 'My Document.pdf',
  );

  if (uploadResult.success) {
    print('File uploaded: ${uploadResult.file.id}');
  } else {
    print('Upload failed: ${uploadResult.error}');
  }

  // Download a file
  try {
    final downloadedFile = await driveService.downloadFile(
      uploadResult.file.id,
      fileName: 'downloaded_file.pdf',
    );
    print('File downloaded to: ${downloadedFile.path}');
  } catch (e) {
    print('Download failed: $e');
  }
}
```

### Advanced Usage

#### List Files

```dart
// List all files
final files = await driveService.listFiles();

// List files in a specific folder
final folderFiles = await driveService.listFiles(
  folderId: 'folder_id_here',
);

// Search for files
final searchResults = await driveService.listFiles(
  query: "name contains 'important'",
  pageSize: 50,
);
```

#### Upload to Specific Folder

```dart
final result = await driveService.uploadFile(
  file,
  fileName: 'report.pdf',
  folderId: 'your_folder_id',
);
```

#### Overwrite Existing File

```dart
final result = await driveService.uploadFile(
  file,
  fileName: 'existing_file.pdf',
  overwrite: true,
);
```

#### Create Folder

```dart
final folder = await driveService.createFolder(
  folderName: 'My New Folder',
  parentFolderId: 'parent_folder_id', // Optional, defaults to root
);
```

#### Get File Information

```dart
// Get file by ID
final file = await driveService.getFileById('file_id_here');

// Get file by name
final file = await driveService.getFileByName('myfile.pdf');
```

#### Delete File

```dart
await driveService.deleteFile('file_id_here');
```

#### Check Authentication Status

```dart
// Check if user is signed in
final isSignedIn = await driveService.isSignedIn();

// Get current user
final user = await driveService.getCurrentUser();

// Sign out
await driveService.signOut();
```

#### Custom Scopes

```dart
final driveService = GoogleDriveService(
  scopes: [
    'https://www.googleapis.com/auth/drive.file',
    // Add custom scopes here
  ],
);
```

## API Reference

### GoogleDriveService

Main service class for Google Drive operations.

#### Constructor

```dart
GoogleDriveService({
  List<String>? scopes,
  GoogleSignIn? googleSignIn,
})
```

#### Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `signIn()` | Signs in the user and obtains access token | `Future<GoogleSignInAccount>` |
| `signOut()` | Signs out the current user | `Future<void>` |
| `isSignedIn()` | Checks if user is currently signed in | `Future<bool>` |
| `getCurrentUser()` | Gets the current signed-in account | `Future<GoogleSignInAccount?>` |
| `uploadFile(file, {fileName, folderId, overwrite})` | Uploads a file to Google Drive | `Future<UploadResult>` |
| `downloadFile(fileId, {savePath, fileName})` | Downloads a file from Google Drive | `Future<File>` |
| `listFiles({folderId, query, pageSize})` | Lists files in Google Drive | `Future<List<DriveFile>>` |
| `getFileById(fileId)` | Gets a file by its ID | `Future<DriveFile>` |
| `getFileByName(fileName, {folderId})` | Gets a file by its name | `Future<DriveFile?>` |
| `deleteFile(fileId)` | Deletes a file from Google Drive | `Future<void>` |
| `createFolder({folderName, parentFolderId})` | Creates a folder in Google Drive | `Future<DriveFile>` |

### Models

#### DriveFile

Represents a file in Google Drive.

```dart
class DriveFile {
  final String id;
  final String name;
  final String? mimeType;
  final int? size;
  final DateTime? modifiedTime;
  final DateTime? createdTime;
  final List<String>? parents;
  final String? webViewLink;
  final String? webContentLink;
}
```

#### UploadResult

Result of an upload operation.

```dart
class UploadResult {
  final bool success;
  final DriveFile? file;
  final String? error;
  
  static UploadResult success(DriveFile file);
  static UploadResult failure(String error);
}
```

### Exceptions

The package throws specific exceptions for different error scenarios:

| Exception | Description |
|-----------|-------------|
| `GoogleDriveException` | Base exception class |
| `AuthenticationException` | Authentication failures |
| `FileOperationException` | General file operation failures |
| `FileNotFoundException` | File not found errors |
| `UploadException` | Upload failures |
| `DownloadException` | Download failures |

## Error Handling

Always wrap your calls in try-catch blocks:

```dart
try {
  final file = await driveService.downloadFile('file_id');
  // Handle success
} on FileNotFoundException {
  // Handle file not found
  print('File not found');
} on AuthenticationException catch (e) {
  // Handle authentication error
  print('Auth error: ${e.message}');
} on DownloadException catch (e) {
  // Handle download error
  print('Download error: ${e.message}');
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

## Permissions

This package requires the following Google Drive scopes:

- `https://www.googleapis.com/auth/drive.file` - Access files created by the app
- `https://www.googleapis.com/auth/drive` - Full access to Drive (included by default)

## Notes

- The package automatically handles token refresh
- Google Workspace files (Docs, Sheets, Slides) are exported as PDF when downloaded
- Upload operations support both `File` objects and file paths as strings
- Files are downloaded to the temp directory by default if no save path is specified
- The package uses the default Google Sign-In configuration from your app

## Troubleshooting

### 403 Access Denied Error

If you encounter a 403 error:

1. Verify SHA-1 fingerprint is added in Google Cloud Console
2. Check package name matches exactly
3. Ensure OAuth consent screen is configured
4. Add your email as a test user (if app is in Testing mode)
5. Enable Google Drive API
6. Wait 5-10 minutes for changes to propagate

### Getting SHA-1 Fingerprint

```bash
# Debug keystore
keytool -keystore ~/.android/debug.keystore -list -v -alias androiddebugkey -storepass android -keypass android

# Or using Gradle
cd android
./gradlew signingReport
```

## Example

See the [example](example/) directory for a complete Flutter app demonstrating all features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/yourusername/i_google_drive/issues).
