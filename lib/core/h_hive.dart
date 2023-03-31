import 'package:hive_flutter/hive_flutter.dart';

class HHive {
  static late Box database;

  Future init() async {
    await Hive.initFlutter();
    database = await Hive.openBox('database');
  }

  static Future<dynamic> getFromDatabase(key) async {
    return await database.get(key);
  }

  static Future putToDatabase(key, value) async {
    await database.put(key, value);
  }
}

enum HiveKeys {
  password,
}
