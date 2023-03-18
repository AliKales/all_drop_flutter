import 'package:all_drop/common_libs.dart';
import 'package:all_drop/pages/error.dart';
import 'package:dio/dio.dart';

import '../settings.dart';

class DDio {
  static void download(
    BuildContext context,
    String urlPath,
    String fullName, {
    void Function(int, int)? onProgress,
  }) {
    try {
      Dio().download(
        urlPath,
        fullName,
        onReceiveProgress: onProgress,
      );
    } catch (e) {
      context.navigatorPush(ErrorPage(error: e.toString()));
    }
  }
}
