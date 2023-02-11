import 'package:dio/dio.dart';

class DDio {
  static void download(
    String urlPath,
    String fullName, {
    void Function(int, int)? onProgress,
  }) {
    Dio().download(
      urlPath,
      "/storage/emulated/0/Download/$fullName",
      onReceiveProgress: onProgress,
    );
  }
}
