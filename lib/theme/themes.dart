import 'package:flutter/material.dart';

// The background color extracted exactly from the dark grey of the logo
const Color _logoBackgroundDark = Color(0xFF1C1D21);

// ==========================================
// Theme: Electric Aqua (Cyan/Blue)
// ==========================================
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00E5FF), // Bright Cyan
    brightness: Brightness.light,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _logoBackgroundDark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00E5FF), // Bright Cyan
    brightness: Brightness.dark,
    surface: _logoBackgroundDark,
  ),
);

const LinearGradient appGradient = LinearGradient(
  colors: [
    Color(0xFF00E5FF), // Cyan
    Color(0xFF8A2BE2), // Purple connection
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

// ==========================================
// Theme Extension for Gradients
// ==========================================
extension ThemeGradientExtension on ThemeData {
  LinearGradient get customGradient {
    return appGradient;
  }
}
