import 'package:all_drop/core/models/m_settings.dart';
import 'package:all_drop/router.dart';

class Settings {
  static bool isMeChecked = false;

  static List<String> routes = [PagePaths.main];

  static String pathToDownloadFile = "/storage/emulated/0/Download";

  static MSettings? settings;
}
