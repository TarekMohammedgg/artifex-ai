import 'package:artifex_ai/theme/dark_mode.dart';
import 'package:artifex_ai/theme/light_mode.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;
  set themeData(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  bool get isDark => _themeData == darkMode;

  void toggleTheme() {
    if (themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
