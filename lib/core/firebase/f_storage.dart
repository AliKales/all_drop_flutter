import 'dart:io';

import 'package:all_drop/common_libs.dart';
import 'package:all_drop/core/firebase/f_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FStorage {
  static void uploadFile(
    File file,
    String type,
    Function(String?) onProgress,
    Function(String) onDone,
    VoidCallback onError,
  ) {
    var ref = FirebaseStorage.instance.ref("files/${FAuth.getUid}/file.$type");

    var task = ref.putFile(file);

    task.onError((error, stackTrace) {
      onError.call();
      return task.snapshot;
    });

    task.snapshotEvents.listen((event) async {
      if (event.bytesTransferred == event.totalBytes) {
        onProgress.call(null);
        onDone.call(await ref.getDownloadURL());
      } else {
        onProgress.call("${event.bytesTransferred}/${event.totalBytes}");
      }
    });
  }

  static Future<bool> deleteLastFile(String type) async {
    var ref = FirebaseStorage.instance.ref("files/${FAuth.getUid}/file.$type");

    try {
      await ref.delete();
    } catch (_) {}
    return true;
  }
}
