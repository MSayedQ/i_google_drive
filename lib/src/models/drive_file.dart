/// Represents a file in Google Drive
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

  const DriveFile({
    required this.id,
    required this.name,
    this.mimeType,
    this.size,
    this.modifiedTime,
    this.createdTime,
    this.parents,
    this.webViewLink,
    this.webContentLink,
  });

  factory DriveFile.fromJson(Map<String, dynamic> json) {
    return DriveFile(
      id: json['id'] as String,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String?,
      size: json['size'] != null ? int.tryParse(json['size'].toString()) : null,
      modifiedTime: json['modifiedTime'] != null
          ? DateTime.parse(json['modifiedTime'] as String)
          : null,
      createdTime: json['createdTime'] != null
          ? DateTime.parse(json['createdTime'] as String)
          : null,
      parents: json['parents'] != null
          ? List<String>.from(json['parents'] as List)
          : null,
      webViewLink: json['webViewLink'] as String?,
      webContentLink: json['webContentLink'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'size': size,
      'modifiedTime': modifiedTime?.toIso8601String(),
      'createdTime': createdTime?.toIso8601String(),
      'parents': parents,
      'webViewLink': webViewLink,
      'webContentLink': webContentLink,
    };
  }
}
