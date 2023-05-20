import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MFile extends Equatable {
  String? fileName;
  int? fileSize;
  String? fileType;
  DateTime? uploadDate;

  MFile({
    this.fileName,
    this.fileSize,
    this.fileType,
    this.uploadDate,
  });

  @override
  List<Object> get props => [fileName ?? "", fileSize ?? "", fileType ?? ""];

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'uploadDate': FieldValue.serverTimestamp(),
      'readByServer': true,
    };
  }

  factory MFile.fromJson(Map<String, dynamic> json) {
    return MFile(
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      fileType: json['fileType'] as String?,
      uploadDate: (json['uploadDate'] as Timestamp?)?.toDate(),
    );
  }
}
