import 'package:cloud_firestore/cloud_firestore.dart';

class MFile {
  String? downloadUrl;
  String? fileName;
  int? fileSize;
  String? fileType;
  DateTime? uploadDate;

  MFile({
    this.downloadUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.uploadDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'downloadUrl': downloadUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'uploadDate': uploadDate,
    };
  }

  factory MFile.fromJson(Map<String, dynamic> json) {
    return MFile(
      downloadUrl: json['downloadUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      fileType: json['fileType'] as String?,
      uploadDate: (json['uploadDate'] as Timestamp?)?.toDate(),
    );
  }
}
