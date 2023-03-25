import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../settings.dart';

extension NumExtension on num {
  double toDynamicHeight(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return height * this;
  }

  double toDynamicWidth(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width * this;
  }

  double toPercent(num max) {
    return 100 * (this / max);
  }

  ///[zeroToOnePercent] = 0.0->1.0
  double get zeroToOnePercent {
    double result = toInt() * 0.01;
    if (result > 1.0) result = 1.0;
    return result;
  }

  bool isBetween(num start, num end) {
    return this >= start && this <= end;
  }
}

extension IntExtension on int {
  Duration get toDuration => Duration(milliseconds: this);

  int get plusOne => this + 1;
  int get minusOne => this - 1;

  ///[toRandom] generates a random number
  ///Ex: 1.toRandom(5) = 1,2,3,4
  int toRandom(int max) {
    return Random().nextInt(max) + this;
  }

  String get byte {
    int length = toString().length;

    if (length >= 1 && length <= 3) {
      return "$this B";
    } else if (length >= 4 && length <= 6) {
      return "${this / 1000} KB";
    } else if (length >= 7 && length <= 9) {
      return "${this / 1000000} MB";
    } else {
      return "${this / 1000000000} GB";
    }
  }
}

extension ContextExtension on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  void back() {
    if (Navigator.canPop(this)) Navigator.pop(this);
  }

  Widget sizedBox({double height = 0, double width = 0}) {
    return SizedBox(
      height: height * this.height,
      width: width * this.width,
    );
  }

  void afterBuild(Function(Duration) afterBuild) {
    WidgetsBinding.instance.addPostFrameCallback(afterBuild);
  }

  // T provider<T>() {
  //   return Provider.of<T>(this, listen: false);
  // }

  // T providerListen<T>() {
  //   return Provider.of<T>(this);
  // }

  Future<T> navigatorPush<T>(page) async {
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => page);
    var object = await Navigator.push(this, route);
    return object;
  }

  void navigatorPushReplacement(page) {
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => page);
    Navigator.pushReplacement(this, route);
  }

  RelativeRect get toRelativeRec {
    //*get the render box from the context
    final RenderBox renderBox = findRenderObject() as RenderBox;
    //*get the global position, from the widget local position
    final offset = renderBox.localToGlobal(Offset.zero);

    //*calculate the start point in this case, below the button
    final left = offset.dx;
    final top = offset.dy + renderBox.size.height;
    //*The right does not indicates the width
    final right = left + renderBox.size.width;

    return RelativeRect.fromLTRB(left, top, right, 0.0);
  }
}

extension WidgetExtension on Widget {
  Widget? toVisible(bool isVisible) {
    if (isVisible) return null;

    return this;
  }

  Widget toEmpty(bool isVisible) {
    if (isVisible) return const SizedBox.shrink();

    return this;
  }

  Widget loading(bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    return this;
  }

  Widget get center => Center(
        child: this,
      );

  Widget get centerAlign => Align(
        alignment: Alignment.center,
        child: this,
      );

  Widget get left => Align(
        alignment: Alignment.centerLeft,
        child: this,
      );

  Widget get right => Align(
        alignment: Alignment.centerRight,
        child: this,
      );

  Widget get centerColumn => Column(
        children: [
          const Spacer(),
          this,
          const Spacer(),
        ],
      );
  Widget get centerRow => Row(
        children: [
          const Spacer(),
          this,
          const Spacer(),
        ],
      );

  Widget backButton(BuildContext context, [Future<bool> Function()? onBack]) {
    return WillPopScope(
        onWillPop: onBack ??
            () async {
              context.go(Settings.routes[Settings.routes.length - 2]);

              return false;
            },
        child: this);
  }
}

extension TextExtension on Text {
  Widget get toBoldWhite {
    return Text(
      data ?? "",
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget toBold([Color? color]) {
    return Text(
      data ?? "",
      style:
          TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.white),
    );
  }
}

extension FunctionExtension on Function {
  ///[name] returns name of function
  String get name {
    if (kIsWeb) {
      int firstCha = toString().indexOf("from: ") + 6;
      int secondCha = toString().indexOf("(", firstCha);

      return toString().substring(firstCha, secondCha);
    } else {
      int firstCha = toString().indexOf("'") + 1;
      int secondCha = toString().indexOf("':");

      return toString().substring(firstCha, secondCha);
    }
  }

  ///[path] example: /page
  String get path {
    return "/$name";
  }
}

extension TextStyleExtension on TextStyle {
  // TextStyle get colorBW {
  //   return copyWith(color: AppColors().blackOrWhite);
  // }

  // TextStyle get colorBWRevers {
  //   return copyWith(color: AppColors().blackOrWhiteReverse);
  // }

  TextStyle get toBold {
    return copyWith(fontWeight: FontWeight.bold);
  }

  TextStyle get toWhite {
    return copyWith(color: Colors.white);
  }

  TextStyle get toBlack {
    return copyWith(color: const Color(0xFF313644));
  }
}

extension ListExtension<E> on List<E> {
  int get count => length - 1;

  List<E> sublistSafe(int start, [int? end]) {
    if (end != null && end > this.count) {
      end = length;
    }
    return sublist(start, end);
  }
}

extension StringExtension on String? {
  String get fileType => this?.split(".").last ?? "";

  String get shuffled => String.fromCharCodes(this!.runes.toList()..shuffle());

  int get toInt {
    return int.tryParse(this ?? "") ?? 0;
  }

  double get toDouble {
    return double.tryParse(this ?? "") ?? 0;
  }

  String get toStringFromDate {
    DateTime? dateTime = DateTime.tryParse(this ?? "");

    if (dateTime == null) return "";

    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  // String localize(Map<String, String> supplants) {
  //   if (this == null) return "error";
  //   return StringUtils.supplant(this!, supplants);
  // }

  String get removeLast {
    if (isEmptyOrNull) return "";
    return this!.substring(0, this!.length - 1);
  }

  DateTime? get toDateTime {
    return DateTime.tryParse(this ?? "");
  }

  bool get isNotEmptyAndNull {
    return this != null && this!.trim() != "";
  }

  bool get isEmptyOrNull {
    return this == null || this?.trim() == "";
  }

  bool get toBool {
    if ((this?.toLowerCase() ?? "true") == "true") {
      return true;
    } else {
      return false;
    }
  }
}

extension DateTimeExtension on DateTime {
  String get hhMM {
    return toString().substring(11, 16);
  }

  String get hh {
    return toString().substring(11, 13);
  }

  String get mm {
    return toString().substring(14, 16);
  }

  String get toStringFromDate {
    return "$day/$month/$year";
  }

  DateTime get toLocalDate {
    var now = DateTime.now();
    return add(now.timeZoneOffset);
  }
}

extension ScrollControllerExtension on ScrollController {
  double get max {
    return position.maxScrollExtent;
  }
}

extension TextEditingExtension on TextEditingController {
  String get textTrim {
    return text.trim();
  }

  bool get isEmpty {
    return text.trim() == "";
  }
}

extension BoolExtension on bool? {
  bool get isFalse {
    if (this == null) return false;

    return this == false;
  }

  bool get isTrue {
    if (this == null) return false;

    return this == true;
  }
}
