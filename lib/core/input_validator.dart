import 'package:artifex_ai/consts.dart';

/// Input validation utilities for user prompts and content
class InputValidator {
  /// Validates a text prompt for AI chat
  /// Returns null if valid, error message if invalid
  static String? validatePrompt(String? prompt) {
    if (prompt == null || prompt.trim().isEmpty) {
      return ValidationMessages.emptyPrompt;
    }

    final trimmed = prompt.trim();

    if (trimmed.length < AiConfig.minPromptLength) {
      return ValidationMessages.promptTooShort;
    }

    if (trimmed.length > AiConfig.maxPromptLength) {
      return ValidationMessages.promptTooLong;
    }

    return null; // Valid
  }

  /// Validates image paths for image-based chats
  static String? validateImages(List<String?>? imagePaths) {
    if (imagePaths == null || imagePaths.isEmpty) {
      return null; // Images are optional for most cases
    }

    // Check if any valid paths exist
    final validPaths = imagePaths.where((p) => p != null && p.isNotEmpty);
    if (validPaths.isEmpty && imagePaths.isNotEmpty) {
      return ValidationMessages.noImageSelected;
    }

    return null; // Valid
  }

  /// Validates image generation prompt
  static String? validateImagePrompt(String? prompt) {
    final baseValidation = validatePrompt(prompt);
    if (baseValidation != null) return baseValidation;

    // Additional check for image generation - needs more detail
    if (prompt!.trim().length < 3) {
      return "Please provide more details for image generation";
    }

    return null;
  }

  /// Sanitizes input by removing excess whitespace and trimming
  static String sanitize(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
