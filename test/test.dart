import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Byte", () {
    var mb = 1226632 / 1000000;

    print(mb);
    print(mb.toInt());
    print(mb.toDouble());
    print(mb.abs());
    print(mb.ceil());
    print(mb.floor());
    print(mb.round());
    print(mb.toStringAsFixed(2));
  });
}
