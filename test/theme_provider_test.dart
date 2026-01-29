import 'package:artifex_ai/theme/dark_mode.dart';
import 'package:artifex_ai/theme/light_mode.dart';
import 'package:artifex_ai/theme/toggle_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeProvider', () {
    test('initial theme is light mode', () {
      final provider = ThemeProvider();
      expect(provider.themeData, equals(lightMode));
      expect(provider.isDark, isFalse);
    });

    test('toggleTheme switches to dark mode', () {
      final provider = ThemeProvider();
      provider.toggleTheme();
      expect(provider.themeData, equals(darkMode));
      expect(provider.isDark, isTrue);
    });

    test('toggleTheme switches back to light mode', () {
      final provider = ThemeProvider();
      provider.toggleTheme(); // to dark
      provider.toggleTheme(); // back to light
      expect(provider.themeData, equals(lightMode));
      expect(provider.isDark, isFalse);
    });

    test('setting themeData directly works', () {
      final provider = ThemeProvider();
      provider.themeData = darkMode;
      expect(provider.themeData, equals(darkMode));
      expect(provider.isDark, isTrue);
    });
  });
}
