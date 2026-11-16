import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variable access with safe fallbacks
/// API keys are loaded from .env file at runtime
abstract class Env {
  /// Remove.bg API Key for background removal
  static String get removebgApiKey => dotenv.env['REMOVEBG_API_KEY'] ?? '';

  /// Stability AI API Key (optional)
  static String get stabilityApiKey => dotenv.env['STABILITY_API_KEY'] ?? '';

  /// Hugging Face Token (optional)
  static String get hfToken => dotenv.env['HF_TOKEN'] ?? '';

  /// Hugging Face API Key (optional)
  static String get huggingfaceApiKey =>
      dotenv.env['HUGGINGFACE_API_KEY'] ?? '';

  /// Check if environment is properly loaded
  static bool get isLoaded => dotenv.isInitialized;
}
