import 'dart:ffi';

import 'package:all_drop/core/firebase/f_auth.dart';
import 'package:all_drop/core/models/m_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Collections { files, usersServerSide }

class FCloudDb {
  static Future<MFile?> getFile() async {
    var result = await FirebaseFirestore.instance
        .collection(Collections.files.name)
        .doc(FAuth.getUid)
        .get();

    if (!result.exists) return null;

    return MFile.fromJson(result.data() as Map<String, dynamic>);
  }

  static Future<bool> setFileInfo(MFile file) async {
    await FirebaseFirestore.instance
        .collection(Collections.files.name)
        .doc(FAuth.getUid)
        .set(file.toJson());
    return true;
  }

  static Future<bool> updateFileInfo(String downloadUrl) async {
    await FirebaseFirestore.instance
        .collection(Collections.files.name)
        .doc(FAuth.getUid)
        .update({
      'downloadUrl': downloadUrl,
    });
    return true;
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> listenSizes() {
    return FirebaseFirestore.instance
        .collection(Collections.usersServerSide.name)
        .doc(FAuth.getUid)
        .snapshots();
  }
}
