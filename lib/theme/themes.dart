import 'package:flutter/material.dart';

// Brand colors derived directly from the primary logo
const Color primaryBrandColor = Color(0xFF6A3DE8); // Electric Violet
const Color accentBrandColor = Color(0xFF56D5E2); // Vivid Cyan / Aqua
const Color darkSurfaceColor = Color(0xFF14131E); // Deep Slate Violet

// ==========================================
// Theme: Artifex Electric Violet & Aqua
// ==========================================
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryBrandColor,
    primary: primaryBrandColor,
    secondary: accentBrandColor,
    brightness: Brightness.light,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkSurfaceColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryBrandColor,
    primary: primaryBrandColor,
    secondary: accentBrandColor,
    brightness: Brightness.dark,
    surface: darkSurfaceColor,
  ),
);

const LinearGradient appGradient = LinearGradient(
  colors: [
    primaryBrandColor, // Electric Violet #6A3DE8
    accentBrandColor, // Vivid Cyan #56D5E2
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
