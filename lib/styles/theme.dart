

import '../common_libs.dart';

class CustomTheme {
  final ColorScheme _colorScheme = const ColorScheme.light(
    primary: Color(0xFFd8488f),
    onTertiary: Color(0xFFdcd2d1),
    shadow: Color(0xFF313644),
  );

  ThemeData themeData() {
    return ThemeData.from(colorScheme: _colorScheme, useMaterial3: true)
        .copyWith(
            snackBarTheme: SnackBarThemeData(
      backgroundColor: _colorScheme.shadow,
    ));
  }
}
