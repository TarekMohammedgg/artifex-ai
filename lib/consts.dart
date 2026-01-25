import 'dart:ui';

import 'package:flutter/material.dart';

/// Application constants that don't contain sensitive information
/// API keys have been moved to environment variables (see lib/core/env.dart)

/// Main gradient used throughout the app
const LinearGradient artifexGradient = LinearGradient(
  colors: [
    Color(0xFF4A00E0), // deep blue-violet
    Color(0xFF5A5CB4), // mid violet-blue
    Color(0xFFFF0080), // pink-magenta
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// AI Chat Configuration
class AiConfig {
  static const String defaultModel = "gemini-2.5-flash";
  static const int maxPromptLength = 30000;
  static const int minPromptLength = 1;
}

/// Input Validation Messages
class ValidationMessages {
  static const String emptyPrompt = "Please enter a message";
  static const String promptTooLong =
      "Message is too long (max 30,000 characters)";
  static const String promptTooShort = "Message is too short";
  static const String noImageSelected = "Please select at least one image";
  static const String invalidImageFormat = "Invalid image format";
}
