# i_google_drive Example

This example demonstrates how to use the `i_google_drive` package in a Flutter application.

## Features Demonstrated

- Google Sign-In authentication
- List files from Google Drive
- Upload files to Google Drive
- Download files from Google Drive
- Delete files from Google Drive
- Error handling and user feedback

## Setup

1. **Configure Google Cloud Console** (see main README.md)
2. **Get dependencies:**
   ```bash
   cd example
   flutter pub get
   ```
3. **Run the example:**
   ```bash
   flutter run
   ```

## Usage

1. Click "Sign In" to authenticate with Google
2. Once signed in, you can:
   - Upload files using the "Upload File" button
   - View all files in your Drive
   - Download files by clicking the menu icon on each file
   - Delete files by selecting "Delete" from the menu
   - Refresh the file list

## Notes

- Make sure you've configured Google Sign-In properly (see main README.md)
- The example uses `file_picker` for selecting files to upload
- Files are downloaded to the app's temporary directory

