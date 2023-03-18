import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common_libs.dart';
import 'firebase/f_auth.dart';

class Utils {
  static DateTime get globalDateTime {
    var now = DateTime.now();
    return now.subtract(now.timeZoneOffset);
  }

  static String dateTimeToId([DateTime? dateTime, bool isWithUId = false]) {
    return (dateTime ?? globalDateTime)
            .toString()
            .replaceAllMapped(RegExp(r'[-:. ]'), (match) => "")
            .substring(0, 14) +
        (isWithUId ? FAuth.getUid!.substring(0, 8) : "");
  }

  static String dateTimeToIdWithUID([DateTime? dateTime]) {
    return (dateTime ?? globalDateTime)
            .toString()
            .replaceAllMapped(RegExp(r'[-:. ]'), (match) => "")
            .substring(0, 12) +
        (FAuth.getUid?.substring(0, 5) ?? "");
  }

  static String dateToDetailedId() {
    return (globalDateTime)
            .toString()
            .replaceAllMapped(RegExp(r'[-:. ]'), (match) => "") +
        (FAuth.getUid?.substring(0, 5) ?? "");
  }

  static Size measure(String text, TextStyle style,
      {int maxLines = 1, TextDirection direction = TextDirection.ltr}) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: maxLines,
        textDirection: direction)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  ///[loadLocalJson] returns json object from the path that's been sent.
  ///If [values] is not empty, then function will go on the value/values and return them
  static Future loadLocalJson(String path, [List<String>? values]) async {
    if (!path.endsWith(".json")) {
      throw Exception("Only json files are supported!");
    }

    var varToReturn;

    final String response = await rootBundle.loadString(path);
    final data = await json.decode(response);

    if (values == null) {
      varToReturn = data;
    } else {
      varToReturn = data;
      for (var i = 0; i < values.length; i++) {
        varToReturn = varToReturn[values[i]];
      }
    }

    return varToReturn;
  }

  static Future<bool> askPermissions(List<Permission> permissions) async {
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    return statuses.values
            .toList()
            .indexWhere((element) => element != PermissionStatus.granted) ==
        -1;
  }

  static Future<bool> isFileExists(String path) async {
    return await File(path).exists();
  }

  static Future copyToClipBoard(
    String value, [
    String? message,
    BuildContext? context,
  ]) async {
    await Clipboard.setData(ClipboardData(text: value));
  }
}
