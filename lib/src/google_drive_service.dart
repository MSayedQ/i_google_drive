import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'dart:convert';

import 'exceptions/google_drive_exception.dart';
import 'models/drive_file.dart';
import 'models/upload_result.dart';

/// Service class for interacting with Google Drive API
class GoogleDriveService {
  static const String _driveApiBaseUrl = 'https://www.googleapis.com/drive/v3';
  static const String _driveUploadApiUrl =
      'https://www.googleapis.com/upload/drive/v3/files';

  final GoogleSignIn _googleSignIn;
  String? _accessToken;

  /// Creates a new instance of GoogleDriveService
  ///
  /// [scopes] - Optional list of additional scopes. By default, includes
  /// 'https://www.googleapis.com/auth/drive.file' scope for file operations.
  GoogleDriveService({
    List<String>? scopes,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: scopes ??
                  [
                    'https://www.googleapis.com/auth/drive.file',
                    'https://www.googleapis.com/auth/drive',
                  ],
            ) {
    print('[GoogleDriveService] Initialized with scopes: ${scopes ?? [
          'drive.file',
          'drive'
        ]}');
  }

  /// Signs in the user and obtains access token
  ///
  /// Returns the authenticated GoogleSignInAccount
  /// Throws [AuthenticationException] if sign-in fails
  Future<GoogleSignInAccount> signIn() async {
    print('[GoogleDriveService] signIn() called');
    try {
      print('[GoogleDriveService] Attempting to sign in...');
      
      // Check if already signed in
      final currentUser = await _googleSignIn.signInSilently();
      if (currentUser != null) {
        print('[GoogleDriveService] Already signed in as: ${currentUser.email}');
        final authentication = await currentUser.authentication;
        _accessToken = authentication.accessToken;
        if (_accessToken != null) {
          print('[GoogleDriveService] Using existing authentication');
          return currentUser;
        }
      }
      
      print('[GoogleDriveService] Requesting new sign-in...');
      final account = await _googleSignIn.signIn();
      if (account == null) {
        print('[GoogleDriveService] Sign in was cancelled by user');
        throw const AuthenticationException('Sign in was cancelled by user');
      }

      print(
          '[GoogleDriveService] Sign in successful, getting authentication token for: ${account.email}');
      final authentication = await account.authentication;
      print('[GoogleDriveService] Authentication response received. Access token: ${authentication.accessToken != null ? "present" : "null"}');
      print('[GoogleDriveService] Id token: ${authentication.idToken != null ? "present" : "null"}');
      
      _accessToken = authentication.accessToken;

      if (_accessToken == null) {
        print('[GoogleDriveService] ERROR: Failed to obtain access token');
        throw const AuthenticationException(
          'Failed to obtain access token. This usually means:\n'
          '1. SHA1 fingerprint is not registered in Google Cloud Console\n'
          '2. OAuth consent screen is not properly configured\n'
          '3. Your email is not added as a test user\n'
          '4. Google Drive API is not enabled',
        );
      }

      print('[GoogleDriveService] Access token obtained successfully');
      return account;
    } on AuthenticationException catch (e) {
      print('[GoogleDriveService] AuthenticationException caught: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('[GoogleDriveService] ERROR in signIn(): $e');
      print('[GoogleDriveService] Stack trace: $stackTrace');
      if (e.toString().contains('403') || e.toString().contains('access_denied')) {
        throw AuthenticationException(
          'Access denied (403). Please check:\n'
          '1. SHA1 fingerprint is added in Google Cloud Console\n'
          '2. Package name matches: com.ibytes.ichat\n'
          '3. OAuth consent screen is configured\n'
          '4. Your email is added as a test user\n'
          '5. Google Drive API is enabled\n'
          'Original error: ${e.toString()}',
        );
      }
      throw AuthenticationException('Sign in failed: ${e.toString()}');
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    print('[GoogleDriveService] signOut() called');
    try {
      await _googleSignIn.signOut();
      _accessToken = null;
      print('[GoogleDriveService] Sign out successful');
    } catch (e) {
      print('[GoogleDriveService] ERROR in signOut(): $e');
      rethrow;
    }
  }

  /// Gets the current signed-in account
  Future<GoogleSignInAccount?> getCurrentUser() async {
    print('[GoogleDriveService] getCurrentUser() called');
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        print('[GoogleDriveService] Current user: ${account.email}');
      } else {
        print('[GoogleDriveService] No current user found');
      }
      return account;
    } catch (e) {
      print('[GoogleDriveService] ERROR in getCurrentUser(): $e');
      return null;
    }
  }

  /// Checks if user is currently signed in
  Future<bool> isSignedIn() async {
    print('[GoogleDriveService] isSignedIn() called');
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        print('[GoogleDriveService] User found, checking authentication token');
        final authentication = await account.authentication;
        _accessToken = authentication.accessToken;
        final isSignedIn = _accessToken != null;
        print('[GoogleDriveService] isSignedIn result: $isSignedIn');
        return isSignedIn;
      }
      print('[GoogleDriveService] No user account found, returning false');
      return false;
    } catch (e) {
      print('[GoogleDriveService] ERROR in isSignedIn(): $e');
      return false;
    }
  }

  /// Ensures user is authenticated, signs in if necessary
  Future<void> _ensureAuthenticated() async {
    print('[GoogleDriveService] _ensureAuthenticated() called');
    if (_accessToken == null) {
      print(
          '[GoogleDriveService] No access token found, attempting silent sign in');
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        print(
            '[GoogleDriveService] Silent sign in successful for: ${account.email}');
        final authentication = await account.authentication;
        _accessToken = authentication.accessToken;
      }

      if (_accessToken == null) {
        print(
            '[GoogleDriveService] Silent sign in failed, requesting user sign in');
        await signIn();
      } else {
        print(
            '[GoogleDriveService] Authentication ensured with existing token');
      }
    } else {
      print('[GoogleDriveService] Already authenticated with existing token');
    }
  }

  /// Gets the access token, refreshing if necessary
  Future<String> _getAccessToken() async {
    print('[GoogleDriveService] _getAccessToken() called');
    await _ensureAuthenticated();

    // Try to get fresh token
    print('[GoogleDriveService] Attempting to get fresh token');
    final account = await _googleSignIn.signInSilently();
    if (account != null) {
      try {
        final authentication = await account.authentication;
        _accessToken = authentication.accessToken ?? _accessToken;
        print('[GoogleDriveService] Fresh token obtained');
      } catch (e) {
        print('[GoogleDriveService] ERROR getting fresh token: $e');
        // Token might be expired, try to refresh by signing in again
        if (_accessToken == null) {
          print('[GoogleDriveService] No token available, requesting sign in');
          await signIn();
        }
      }
    }

    if (_accessToken == null) {
      print('[GoogleDriveService] ERROR: No valid access token available');
      throw const AuthenticationException(
        'No valid access token available. Please sign in again.',
      );
    }

    print('[GoogleDriveService] Access token ready');
    return _accessToken!;
  }

  /// Handles authentication errors and retries with fresh token
  Future<T> _retryWithAuth<T>(
    Future<T> Function() operation,
  ) async {
    print('[GoogleDriveService] _retryWithAuth() called');
    try {
      print('[GoogleDriveService] Attempting operation');
      return await operation();
    } on AuthenticationException catch (e) {
      print('[GoogleDriveService] AuthenticationException caught: $e');
      rethrow;
    } catch (e) {
      print('[GoogleDriveService] Error in operation: $e');
      // If it's an auth error (401), try refreshing token
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        print(
            '[GoogleDriveService] Auth error detected (401), refreshing token and retrying');
        // Clear current token and try to get a fresh one
        _accessToken = null;
        await _ensureAuthenticated();
        // Retry the operation once
        print('[GoogleDriveService] Retrying operation with fresh token');
        return await operation();
      }
      print('[GoogleDriveService] Non-auth error, rethrowing');
      rethrow;
    }
  }

  /// Uploads a file to Google Drive
  ///
  /// [file] - The file to upload (File object or path as String)
  /// [fileName] - Optional custom name for the file in Drive
  /// [folderId] - Optional folder ID to upload to (default: root)
  /// [overwrite] - If true and file exists, it will be updated
  ///
  /// Returns [UploadResult] with the uploaded file information
  Future<UploadResult> uploadFile(
    dynamic file, {
    String? fileName,
    String? folderId,
    bool overwrite = false,
  }) async {
    print(
        '[GoogleDriveService] uploadFile() called with fileName: $fileName, folderId: $folderId, overwrite: $overwrite');
    try {
      final accessToken = await _getAccessToken();
      File fileToUpload;

      // Handle both File object and String path
      if (file is File) {
        fileToUpload = file;
        print(
            '[GoogleDriveService] File provided as File object: ${file.path}');
      } else if (file is String) {
        fileToUpload = File(file);
        print('[GoogleDriveService] File provided as String path: $file');
      } else {
        print('[GoogleDriveService] ERROR: Invalid file parameter type');
        throw const UploadException('Invalid file parameter');
      }

      if (!await fileToUpload.exists()) {
        print(
            '[GoogleDriveService] ERROR: File does not exist: ${fileToUpload.path}');
        throw UploadException('File does not exist: ${fileToUpload.path}');
      }

      final fileSize = await fileToUpload.length();
      print('[GoogleDriveService] File exists, size: $fileSize bytes');

      final actualFileName = fileName ?? fileToUpload.path.split('/').last;
      print('[GoogleDriveService] Uploading file as: $actualFileName');
      final fileContent = await fileToUpload.readAsBytes();
      final mimeType =
          lookupMimeType(actualFileName) ?? 'application/octet-stream';
      print('[GoogleDriveService] Detected MIME type: $mimeType');

      // Check if file exists and get ID if overwrite is enabled
      String? existingFileId;
      if (overwrite) {
        print(
            '[GoogleDriveService] Overwrite enabled, checking for existing file');
        try {
          final existingFile =
              await getFileByName(actualFileName, folderId: folderId);
          if (existingFile != null) {
            existingFileId = existingFile.id;
            print(
                '[GoogleDriveService] Existing file found with ID: $existingFileId');
          } else {
            print(
                '[GoogleDriveService] No existing file found, will create new');
          }
        } catch (e) {
          print(
              '[GoogleDriveService] Error checking for existing file: $e, continuing with upload');
          // File doesn't exist, continue with upload
        }
      }

      final uploadUrl = existingFileId != null
          ? '$_driveUploadApiUrl/$existingFileId?uploadType=multipart'
          : '$_driveUploadApiUrl?uploadType=multipart';
      print(
          '[GoogleDriveService] Upload URL: $uploadUrl (${existingFileId != null ? 'PATCH' : 'POST'})');

      // Prepare metadata
      final metadata = {
        'name': actualFileName,
        if (folderId != null) 'parents': [folderId],
      };

      if (existingFileId != null) {
        metadata['name'] = actualFileName;
      }
      print('[GoogleDriveService] Upload metadata: $metadata');

      // Create multipart request
      final request = http.MultipartRequest(
        existingFileId != null ? 'PATCH' : 'POST',
        Uri.parse(uploadUrl),
      );

      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['metadata'] = jsonEncode(metadata);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileContent,
          filename: actualFileName,
        ),
      );

      print('[GoogleDriveService] Sending upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(
          '[GoogleDriveService] Upload response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final driveFile = DriveFile.fromJson(responseData);
        print(
            '[GoogleDriveService] Upload successful! File ID: ${driveFile.id}, Name: ${driveFile.name}');
        return UploadResult.success(driveFile);
      } else {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorBody['error']?['message'] ?? 'Upload failed';
        print(
            '[GoogleDriveService] Upload failed: $errorMessage (Status: ${response.statusCode})');
        throw UploadException(
          errorMessage,
          response.statusCode,
        );
      }
    } catch (e) {
      print('[GoogleDriveService] ERROR in uploadFile(): $e');
      if (e is GoogleDriveException) {
        return UploadResult.failure(e.message);
      }
      return UploadResult.failure('Upload failed: ${e.toString()}');
    }
  }

  /// Downloads a file from Google Drive
  ///
  /// [fileId] - The ID of the file to download
  /// [savePath] - Optional path to save the file. If not provided, saves to app's temp directory
  /// [fileName] - Optional custom name for the downloaded file
  ///
  /// Returns the [File] object of the downloaded file
  Future<File> downloadFile(
    String fileId, {
    String? savePath,
    String? fileName,
  }) async {
    print(
        '[GoogleDriveService] downloadFile() called with fileId: $fileId, savePath: $savePath, fileName: $fileName');
    try {
      final accessToken = await _getAccessToken();

      // First, get file metadata to determine the actual file name
      print('[GoogleDriveService] Fetching file metadata for: $fileId');
      final metadataUrl = '$_driveApiBaseUrl/files/$fileId';
      final metadataResponse = await http.get(
        Uri.parse(metadataUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print(
          '[GoogleDriveService] Metadata response status: ${metadataResponse.statusCode}');
      if (metadataResponse.statusCode != 200) {
        if (metadataResponse.statusCode == 404) {
          print('[GoogleDriveService] ERROR: File not found (404)');
          throw const FileNotFoundException('File not found');
        }
        final errorBody =
            jsonDecode(metadataResponse.body) as Map<String, dynamic>;
        final errorMessage =
            errorBody['error']?['message'] ?? 'Failed to get file metadata';
        print('[GoogleDriveService] ERROR getting metadata: $errorMessage');
        throw FileOperationException(errorMessage, metadataResponse.statusCode);
      }

      final metadata =
          jsonDecode(metadataResponse.body) as Map<String, dynamic>;
      final driveFile = DriveFile.fromJson(metadata);
      final actualFileName = fileName ?? driveFile.name;
      print(
          '[GoogleDriveService] File metadata retrieved: ${driveFile.name}, Size: ${driveFile.size}, MIME: ${driveFile.mimeType}');

      // Determine save path
      Directory saveDirectory;
      if (savePath != null) {
        saveDirectory = Directory(savePath);
        print('[GoogleDriveService] Using provided save path: $savePath');
      } else {
        saveDirectory = await getTemporaryDirectory();
        print(
            '[GoogleDriveService] Using temp directory: ${saveDirectory.path}');
      }

      if (!await saveDirectory.exists()) {
        print('[GoogleDriveService] Creating save directory');
        await saveDirectory.create(recursive: true);
      }

      final filePath = '${saveDirectory.path}/$actualFileName';
      print('[GoogleDriveService] Will save file to: $filePath');

      // Download file content
      // Use export endpoint for Google Workspace files, or regular download for others
      final mimeType = driveFile.mimeType ?? 'application/octet-stream';
      String downloadUrl;

      if (mimeType.startsWith('application/vnd.google-apps.')) {
        // Google Workspace files need to be exported
        downloadUrl =
            '$_driveApiBaseUrl/files/$fileId/export?mimeType=application/pdf';
        print(
            '[GoogleDriveService] Google Workspace file detected, using export endpoint');
      } else {
        downloadUrl = '$_driveApiBaseUrl/files/$fileId?alt=media';
        print('[GoogleDriveService] Regular file, using download endpoint');
      }

      print('[GoogleDriveService] Downloading file from: $downloadUrl');
      final downloadResponse = await http.get(
        Uri.parse(downloadUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print(
          '[GoogleDriveService] Download response status: ${downloadResponse.statusCode}, Size: ${downloadResponse.bodyBytes.length} bytes');
      if (downloadResponse.statusCode != 200) {
        final errorBody =
            jsonDecode(downloadResponse.body) as Map<String, dynamic>;
        final errorMessage =
            errorBody['error']?['message'] ?? 'Download failed';
        print('[GoogleDriveService] ERROR downloading file: $errorMessage');
        throw DownloadException(errorMessage, downloadResponse.statusCode);
      }

      // Save file
      print('[GoogleDriveService] Saving file to disk...');
      final file = File(filePath);
      await file.writeAsBytes(downloadResponse.bodyBytes);
      print('[GoogleDriveService] File saved successfully: $filePath');
      return file;
    } catch (e) {
      print('[GoogleDriveService] ERROR in downloadFile(): $e');
      if (e is GoogleDriveException) {
        rethrow;
      }
      throw DownloadException('Download failed: ${e.toString()}');
    }
  }

  /// Lists files in Google Drive
  ///
  /// [folderId] - Optional folder ID to list files from (default: root)
  /// [query] - Optional query string to filter files (e.g., "name contains 'test'")
  /// [pageSize] - Maximum number of files to return (default: 100)
  ///
  /// Returns a list of [DriveFile] objects
  Future<List<DriveFile>> listFiles({
    String? folderId,
    String? query,
    int pageSize = 100,
  }) async {
    print(
        '[GoogleDriveService] listFiles() called with folderId: $folderId, query: $query, pageSize: $pageSize');
    return await _retryWithAuth(() async {
      try {
        final accessToken = await _getAccessToken();

        String queryString = '';
        if (folderId != null) {
          queryString = "'$folderId' in parents";
          print('[GoogleDriveService] Filtering by folder: $folderId');
        }
        if (query != null) {
          queryString = queryString.isEmpty ? query : '$queryString and $query';
          print('[GoogleDriveService] Applying query: $query');
        }

        final url =
            Uri.parse('$_driveApiBaseUrl/files').replace(queryParameters: {
          'pageSize': pageSize.toString(),
          if (queryString.isNotEmpty) 'q': queryString,
          'fields':
              'files(id,name,mimeType,size,modifiedTime,createdTime,parents,webViewLink,webContentLink)',
        });

        print(
            '[GoogleDriveService] Requesting files list from: ${url.toString()}');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        print(
            '[GoogleDriveService] List files response status: ${response.statusCode}');
        if (response.statusCode != 200) {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage =
              errorBody['error']?['message'] ?? 'Failed to list files';
          print('[GoogleDriveService] ERROR listing files: $errorMessage');
          throw FileOperationException(errorMessage, response.statusCode);
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final filesList = data['files'] as List? ?? [];
        print('[GoogleDriveService] Retrieved ${filesList.length} files');
        return filesList
            .map((fileJson) =>
                DriveFile.fromJson(fileJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('[GoogleDriveService] ERROR in listFiles(): $e');
        if (e is GoogleDriveException) {
          rethrow;
        }
        throw FileOperationException('Failed to list files: ${e.toString()}');
      }
    });
  }

  /// Gets a file by its ID
  ///
  /// [fileId] - The ID of the file
  ///
  /// Returns the [DriveFile] object
  Future<DriveFile> getFileById(String fileId) async {
    print('[GoogleDriveService] getFileById() called with fileId: $fileId');
    try {
      final accessToken = await _getAccessToken();

      final url = Uri.parse('$_driveApiBaseUrl/files/$fileId').replace(
        queryParameters: {
          'fields':
              'id,name,mimeType,size,modifiedTime,createdTime,parents,webViewLink,webContentLink',
        },
      );

      print('[GoogleDriveService] Fetching file info from: ${url.toString()}');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print(
          '[GoogleDriveService] Get file response status: ${response.statusCode}');
      if (response.statusCode == 404) {
        print('[GoogleDriveService] ERROR: File not found (404)');
        throw const FileNotFoundException('File not found');
      }

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage =
            errorBody['error']?['message'] ?? 'Failed to get file';
        print('[GoogleDriveService] ERROR getting file: $errorMessage');
        throw FileOperationException(errorMessage, response.statusCode);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final driveFile = DriveFile.fromJson(data);
      print('[GoogleDriveService] File retrieved: ${driveFile.name}');
      return driveFile;
    } catch (e) {
      print('[GoogleDriveService] ERROR in getFileById(): $e');
      if (e is GoogleDriveException) {
        rethrow;
      }
      throw FileOperationException('Failed to get file: ${e.toString()}');
    }
  }

  /// Gets a file by its name
  ///
  /// [fileName] - The name of the file
  /// [folderId] - Optional folder ID to search in
  ///
  /// Returns the [DriveFile] object or null if not found
  Future<DriveFile?> getFileByName(String fileName, {String? folderId}) async {
    print(
        '[GoogleDriveService] getFileByName() called with fileName: $fileName, folderId: $folderId');
    try {
      final files = await listFiles(
        folderId: folderId,
        query: "name = '$fileName'",
        pageSize: 1,
      );
      if (files.isNotEmpty) {
        print('[GoogleDriveService] File found: ${files.first.id}');
        return files.first;
      } else {
        print('[GoogleDriveService] File not found');
        return null;
      }
    } catch (e) {
      print('[GoogleDriveService] ERROR in getFileByName(): $e');
      return null;
    }
  }

  /// Deletes a file from Google Drive
  ///
  /// [fileId] - The ID of the file to delete
  Future<void> deleteFile(String fileId) async {
    print('[GoogleDriveService] deleteFile() called with fileId: $fileId');
    try {
      final accessToken = await _getAccessToken();

      final url = Uri.parse('$_driveApiBaseUrl/files/$fileId');
      print('[GoogleDriveService] Deleting file from: ${url.toString()}');

      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print(
          '[GoogleDriveService] Delete response status: ${response.statusCode}');
      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          print('[GoogleDriveService] ERROR: File not found (404)');
          throw const FileNotFoundException('File not found');
        }
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage =
            errorBody['error']?['message'] ?? 'Failed to delete file';
        print('[GoogleDriveService] ERROR deleting file: $errorMessage');
        throw FileOperationException(errorMessage, response.statusCode);
      }
      print('[GoogleDriveService] File deleted successfully');
    } catch (e) {
      print('[GoogleDriveService] ERROR in deleteFile(): $e');
      if (e is GoogleDriveException) {
        rethrow;
      }
      throw FileOperationException('Failed to delete file: ${e.toString()}');
    }
  }

  /// Creates a folder in Google Drive
  ///
  /// [folderName] - Name of the folder to create
  /// [parentFolderId] - Optional parent folder ID (default: root)
  ///
  /// Returns the created [DriveFile] object
  Future<DriveFile> createFolder({
    required String folderName,
    String? parentFolderId,
  }) async {
    print(
        '[GoogleDriveService] createFolder() called with folderName: $folderName, parentFolderId: $parentFolderId');
    try {
      final accessToken = await _getAccessToken();

      final metadata = {
        'name': folderName,
        'mimeType': 'application/vnd.google-apps.folder',
        if (parentFolderId != null) 'parents': [parentFolderId],
      };
      print('[GoogleDriveService] Creating folder with metadata: $metadata');

      final response = await http.post(
        Uri.parse('$_driveApiBaseUrl/files'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(metadata),
      );

      print(
          '[GoogleDriveService] Create folder response status: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final driveFile = DriveFile.fromJson(data);
        print(
            '[GoogleDriveService] Folder created successfully: ${driveFile.id}');
        return driveFile;
      } else {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage =
            errorBody['error']?['message'] ?? 'Failed to create folder';
        print('[GoogleDriveService] ERROR creating folder: $errorMessage');
        throw FileOperationException(errorMessage, response.statusCode);
      }
    } catch (e) {
      print('[GoogleDriveService] ERROR in createFolder(): $e');
      if (e is GoogleDriveException) {
        rethrow;
      }
      throw FileOperationException('Failed to create folder: ${e.toString()}');
    }
  }
}
