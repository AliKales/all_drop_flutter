import 'package:all_drop/core/firebase/f_auth.dart';
import 'package:all_drop/core/models/m_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Collections {
  files,
}

class FCloudDb {
  static Future<MFile?> getFile() async {
    var result = await FirebaseFirestore.instance
        .collection(Collections.files.name)
        .doc(FAuth.getUid)
        .get();

    if (!result.exists) return null;

    return MFile.fromJson(result.data() as Map<String,dynamic>);
  }
}
