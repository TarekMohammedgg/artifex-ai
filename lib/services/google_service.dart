import 'dart:io';
import 'package:artifex_ai/core/error_handling.dart';
import 'package:firebase_ai/firebase_ai.dart';

abstract class GoogleAiService {
  /// Generates text response from AI with proper error handling
  /// Returns a Result containing either the response or an error message
  static Future<Result<String>> generateTextSafe(
    String? notes, [
    List<String?>? imagesPath,
  ]) async {
    return Result.guard(() => generateText(notes, imagesPath));
  }

  /// Generates text response from AI
  /// Throws AiServiceException on error
  static Future<String> generateText(
    String? notes, [
    List<String?>? imagesPath,
  ]) async {
    try {
      // Validate input
      if (notes == null || notes.trim().isEmpty) {
        throw AiServiceException(
          ErrorMessages.emptyResponse,
          code: 'EMPTY_INPUT',
        );
      }

      final model = FirebaseAI.googleAI().generativeModel(
        model: "gemini-2.5-flash",
      );

      final text =
          """
You are a highly advanced engineer and thinker with deep, wide-ranging knowledge across computer science, software engineering, AI, systems design, and general problem-solving.

You are not limited to one specialty — you understand the big picture across many fields and can connect ideas between them to produce elegant, practical, and efficient solutions.

You think and respond with high performance, focusing on clarity, precision, and results.
Your explanations and code are always optimized, clean, and well-structured, following best practices and sound reasoning.

You are an expert refactorer, capable of improving any idea, explanation, or code into its most efficient and readable form.

You care only about understanding deeply, reasoning clearly, and delivering high-quality, actionable output — nothing else.

now answer on the next question: ${notes.trim()}


""";
      final textPart = TextPart(text);

      final List<Part> imagesPart = [];
      if (imagesPath != null && imagesPath.isNotEmpty) {
        for (final path in imagesPath) {
          if (path == null || path.isEmpty) continue;
          final file = File(path);
          if (!file.existsSync()) {
            continue; // Skip non-existent files
          }

          try {
            final bytes = await file.readAsBytes();
            imagesPart.add(InlineDataPart("image/jpeg", bytes));
          } catch (e) {
            // Log but continue with other images
            continue;
          }
        }
      }

      final List<Part> parts = [
        textPart,
        if (imagesPart.isNotEmpty) ...imagesPart,
      ];

      final prompt = Content.multi(parts);

      final response = await model.generateContent([prompt]);
      final result = response.text?.trim();

      if (result == null || result.isEmpty) {
        throw AiServiceException(
          ErrorMessages.emptyResponse,
          code: 'EMPTY_RESPONSE',
        );
      }

      return result;
    } on AiServiceException {
      rethrow;
    } on SocketException catch (e) {
      throw AiServiceException(
        ErrorMessages.networkError,
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    } catch (e) {
      // Check for specific error types
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('api key') ||
          errorString.contains('unauthorized')) {
        throw AiServiceException(
          ErrorMessages.invalidApiKey,
          code: 'INVALID_API_KEY',
          originalError: e,
        );
      }

      if (errorString.contains('rate limit') || errorString.contains('quota')) {
        throw AiServiceException(
          ErrorMessages.rateLimitExceeded,
          code: 'RATE_LIMIT',
          originalError: e,
        );
      }

      if (errorString.contains('safety') || errorString.contains('blocked')) {
        throw AiServiceException(
          ErrorMessages.contentFiltered,
          code: 'CONTENT_FILTERED',
          originalError: e,
        );
      }

      if (errorString.contains('timeout')) {
        throw AiServiceException(
          ErrorMessages.timeout,
          code: 'TIMEOUT',
          originalError: e,
        );
      }

      throw AiServiceException(
        ErrorMessages.unknownError,
        code: 'UNKNOWN',
        originalError: e,
      );
    }
  }
}
