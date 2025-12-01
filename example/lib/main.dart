import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:i_google_drive/i_google_drive.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'i_google_drive Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GoogleDriveExamplePage(),
    );
  }
}

/// Example Flutter page demonstrating Google Drive file operations
class GoogleDriveExamplePage extends StatefulWidget {
  const GoogleDriveExamplePage({super.key});

  @override
  State<GoogleDriveExamplePage> createState() => _GoogleDriveExamplePageState();
}

class _GoogleDriveExamplePageState extends State<GoogleDriveExamplePage> {
  final GoogleDriveService _driveService = GoogleDriveService();
  bool _isLoading = false;
  bool _isSignedIn = false;
  GoogleSignInAccount? _currentUser;
  List<DriveFile> _files = [];
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isSignedIn = await _driveService.isSignedIn();
      final user = await _driveService.getCurrentUser();

      setState(() {
        _isSignedIn = isSignedIn;
        _currentUser = user;
        _isLoading = false;
      });

      if (isSignedIn) {
        await _loadFiles();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking auth status: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final account = await _driveService.signIn();
      setState(() {
        _isSignedIn = true;
        _currentUser = account;
        _isLoading = false;
        _successMessage = 'Signed in successfully as ${account.email}';
      });
      await _loadFiles();
    } on AuthenticationException catch (e) {
      setState(() {
        _errorMessage = 'Authentication error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign in failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _driveService.signOut();
      setState(() {
        _isSignedIn = false;
        _currentUser = null;
        _files = [];
        _isLoading = false;
        _successMessage = 'Signed out successfully';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign out failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final files = await _driveService.listFiles(pageSize: 50);
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load files: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final file = File(filePath);

      if (!await file.exists()) {
        setState(() {
          _errorMessage = 'Selected file does not exist';
          _isLoading = false;
        });
        return;
      }

      final uploadResult = await _driveService.uploadFile(
        file,
        fileName: fileName,
      );

      if (uploadResult.success) {
        setState(() {
          _successMessage =
              'File uploaded successfully: ${uploadResult.file!.name}';
          _isLoading = false;
        });
        await _loadFiles();
      } else {
        setState(() {
          _errorMessage = 'Upload failed: ${uploadResult.error}';
          _isLoading = false;
        });
      }
    } on UploadException catch (e) {
      setState(() {
        _errorMessage = 'Upload error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Upload failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(DriveFile file) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final downloadedFile = await _driveService.downloadFile(
        file.id,
        fileName: 'downloaded_${file.name}',
      );

      setState(() {
        _successMessage = 'File downloaded to: ${downloadedFile.path}';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File downloaded to: ${downloadedFile.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on DownloadException catch (e) {
      setState(() {
        _errorMessage = 'Download error: ${e.message}';
        _isLoading = false;
      });
    } on FileNotFoundException catch (e) {
      setState(() {
        _errorMessage = 'File not found: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Download failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFile(DriveFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _driveService.deleteFile(file.id);
      setState(() {
        _successMessage = 'File deleted successfully';
        _isLoading = false;
      });
      await _loadFiles();
    } catch (e) {
      setState(() {
        _errorMessage = 'Delete failed: $e';
        _isLoading = false;
      });
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.contains('image')) return Icons.image;
    if (mimeType.contains('video')) return Icons.video_file;
    if (mimeType.contains('audio')) return Icons.audiotrack;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('folder') || mimeType.contains('directory')) {
      return Icons.folder;
    }
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('i_google_drive Example'),
        actions: [
          if (_isSignedIn)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadFiles,
              tooltip: 'Refresh files',
            ),
        ],
      ),
      body: _isLoading && _files.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Auth Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_currentUser != null)
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: _currentUser!.photoUrl != null
                                  ? NetworkImage(_currentUser!.photoUrl!)
                                  : null,
                              child: _currentUser!.photoUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentUser!.displayName ?? 'User',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    _currentUser!.email,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : (_isSignedIn ? _signOut : _signIn),
                        icon: Icon(_isSignedIn ? Icons.logout : Icons.login),
                        label: Text(_isSignedIn ? 'Sign Out' : 'Sign In'),
                      ),
                    ],
                  ),
                ),

                // Messages
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.red.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() => _errorMessage = null);
                          },
                        ),
                      ],
                    ),
                  ),
                if (_successMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.green.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() => _successMessage = null);
                          },
                        ),
                      ],
                    ),
                  ),

                // Action Buttons
                if (_isSignedIn)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _uploadFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload File'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _loadFiles,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Files List
                if (_isSignedIn)
                  Expanded(
                    child: _files.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No files found',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _loadFiles,
                                  child: const Text('Refresh'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _files.length,
                            itemBuilder: (context, index) {
                              final file = _files[index];
                              final isFolder = file.mimeType ==
                                  'application/vnd.google-apps.folder';

                              return ListTile(
                                leading: Icon(
                                  _getFileIcon(file.mimeType),
                                  color: isFolder
                                      ? Colors.blue
                                      : Theme.of(context).iconTheme.color,
                                ),
                                title: Text(file.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (file.size != null)
                                      Text(
                                        _formatFileSize(file.size),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    if (file.modifiedTime != null)
                                      Text(
                                        'Modified: ${file.modifiedTime!.toString().split('.')[0]}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'download' && !isFolder) {
                                      _downloadFile(file);
                                    } else if (value == 'delete') {
                                      _deleteFile(file);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (!isFolder)
                                      const PopupMenuItem(
                                        value: 'download',
                                        child: Row(
                                          children: [
                                            Icon(Icons.download, size: 20),
                                            SizedBox(width: 8),
                                            Text('Download'),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                if (!_isSignedIn)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sign in to Google Drive to get started',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

