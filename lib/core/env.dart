import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variable access with secure fallbacks
/// API keys are loaded from .env file at runtime
abstract class Env {
  /// Gemini API Key for Google AI services
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? _throwMissingKey('GEMINI_API_KEY');

  /// Stability AI API Key for image generation
  static String get stabilityApiKey =>
      dotenv.env['STABILITY_API_KEY'] ?? _throwMissingKey('STABILITY_API_KEY');

  /// Remove.bg API Key for background removal
  static String get removebgApiKey =>
      dotenv.env['REMOVEBG_API_KEY'] ?? _throwMissingKey('REMOVEBG_API_KEY');

  /// Hugging Face Token
  static String get hfToken =>
      dotenv.env['HF_TOKEN'] ?? _throwMissingKey('HF_TOKEN');

  /// Hugging Face API Key
  static String get huggingfaceApiKey =>
      dotenv.env['HUGGINGFACE_API_KEY'] ??
      _throwMissingKey('HUGGINGFACE_API_KEY');

  /// Check if environment is properly loaded
  static bool get isLoaded => dotenv.isInitialized;

  /// Throws an exception for missing API keys
  static Never _throwMissingKey(String keyName) {
    throw Exception(
      'Missing environment variable: $keyName. '
      'Please ensure .env file exists and contains $keyName.',
    );
  }
}
