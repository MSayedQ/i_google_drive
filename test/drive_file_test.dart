import 'package:flutter_test/flutter_test.dart';
import 'package:i_google_drive/i_google_drive.dart';

void main() {
  group('DriveFile', () {
    test('should create DriveFile with all properties', () {
      final file = DriveFile(
        id: 'test-id',
        name: 'test-file.pdf',
        mimeType: 'application/pdf',
        size: 1024,
        modifiedTime: DateTime(2024, 1, 1),
        createdTime: DateTime(2024, 1, 1),
        parents: ['parent-id'],
        webViewLink: 'https://drive.google.com/file/view',
        webContentLink: 'https://drive.google.com/file/content',
      );

      expect(file.id, 'test-id');
      expect(file.name, 'test-file.pdf');
      expect(file.mimeType, 'application/pdf');
      expect(file.size, 1024);
      expect(file.modifiedTime, DateTime(2024, 1, 1));
      expect(file.createdTime, DateTime(2024, 1, 1));
      expect(file.parents, ['parent-id']);
      expect(file.webViewLink, 'https://drive.google.com/file/view');
      expect(file.webContentLink, 'https://drive.google.com/file/content');
    });

    test('should create DriveFile with minimal properties', () {
      final file = const DriveFile(
        id: 'test-id',
        name: 'test-file.pdf',
      );

      expect(file.id, 'test-id');
      expect(file.name, 'test-file.pdf');
      expect(file.mimeType, isNull);
      expect(file.size, isNull);
      expect(file.modifiedTime, isNull);
      expect(file.createdTime, isNull);
      expect(file.parents, isNull);
      expect(file.webViewLink, isNull);
      expect(file.webContentLink, isNull);
    });

    test('should create DriveFile from JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'test-file.pdf',
        'mimeType': 'application/pdf',
        'size': '1024',
        'modifiedTime': '2024-01-01T00:00:00.000Z',
        'createdTime': '2024-01-01T00:00:00.000Z',
        'parents': ['parent-id'],
        'webViewLink': 'https://drive.google.com/file/view',
        'webContentLink': 'https://drive.google.com/file/content',
      };

      final file = DriveFile.fromJson(json);

      expect(file.id, 'test-id');
      expect(file.name, 'test-file.pdf');
      expect(file.mimeType, 'application/pdf');
      expect(file.size, 1024);
      expect(file.modifiedTime?.toIso8601String(), '2024-01-01T00:00:00.000Z');
      expect(file.createdTime?.toIso8601String(), '2024-01-01T00:00:00.000Z');
      expect(file.parents, ['parent-id']);
      expect(file.webViewLink, 'https://drive.google.com/file/view');
      expect(file.webContentLink, 'https://drive.google.com/file/content');
    });

    test('should create DriveFile from JSON with null values', () {
      final json = {
        'id': 'test-id',
        'name': 'test-file.pdf',
      };

      final file = DriveFile.fromJson(json);

      expect(file.id, 'test-id');
      expect(file.name, 'test-file.pdf');
      expect(file.mimeType, isNull);
      expect(file.size, isNull);
      expect(file.modifiedTime, isNull);
      expect(file.createdTime, isNull);
      expect(file.parents, isNull);
      expect(file.webViewLink, isNull);
      expect(file.webContentLink, isNull);
    });

    test('should convert DriveFile to JSON', () {
      final file = DriveFile(
        id: 'test-id',
        name: 'test-file.pdf',
        mimeType: 'application/pdf',
        size: 1024,
        modifiedTime: DateTime(2024, 1, 1),
        createdTime: DateTime(2024, 1, 1),
        parents: ['parent-id'],
        webViewLink: 'https://drive.google.com/file/view',
        webContentLink: 'https://drive.google.com/file/content',
      );

      final json = file.toJson();

      expect(json['id'], 'test-id');
      expect(json['name'], 'test-file.pdf');
      expect(json['mimeType'], 'application/pdf');
      expect(json['size'], 1024);
      expect(json['modifiedTime'], '2024-01-01T00:00:00.000');
      expect(json['createdTime'], '2024-01-01T00:00:00.000');
      expect(json['parents'], ['parent-id']);
      expect(json['webViewLink'], 'https://drive.google.com/file/view');
      expect(json['webContentLink'], 'https://drive.google.com/file/content');
    });

    test('should convert DriveFile to JSON with null values', () {
      final file = const DriveFile(
        id: 'test-id',
        name: 'test-file.pdf',
      );

      final json = file.toJson();

      expect(json['id'], 'test-id');
      expect(json['name'], 'test-file.pdf');
      expect(json['mimeType'], isNull);
      expect(json['size'], isNull);
      expect(json['modifiedTime'], isNull);
      expect(json['createdTime'], isNull);
      expect(json['parents'], isNull);
      expect(json['webViewLink'], isNull);
      expect(json['webContentLink'], isNull);
    });

    test('should handle size as int in JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'test-file.pdf',
        'size': 2048,
      };

      final file = DriveFile.fromJson(json);

      expect(file.size, 2048);
    });

    test('should handle size as string in JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'test-file.pdf',
        'size': '2048',
      };

      final file = DriveFile.fromJson(json);

      expect(file.size, 2048);
    });

    test('should handle invalid size in JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'test-file.pdf',
        'size': 'invalid',
      };

      final file = DriveFile.fromJson(json);

      expect(file.size, isNull);
    });
  });
}
