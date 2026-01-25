import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:artifex_ai/core/env.dart';
import 'package:artifex_ai/core/error_handling.dart';
import 'package:stability_image_generation/stability_image_generation.dart';

abstract class StabilityAi {
  static final StabilityAI _ai = StabilityAI();

  /// Generates an image with proper error handling
  /// Returns a Result containing either the image bytes or an error message
  static Future<Result<Uint8List>> generateImageSafe(
    String prompt,
    ImageAIStyle imageAIStyle,
  ) async {
    return Result.guard(() => generateImage(prompt, imageAIStyle));
  }

  /// Generates an image from a text prompt
  /// Throws AiServiceException on error
  static Future<Uint8List> generateImage(
    String prompt,
    ImageAIStyle imageAIStyle,
  ) async {
    try {
      // Validate input
      if (prompt.trim().isEmpty) {
        throw AiServiceException(
          'Please provide a description for the image',
          code: 'EMPTY_PROMPT',
        );
      }

      if (prompt.trim().length < 3) {
        throw AiServiceException(
          'Please provide more details for better results',
          code: 'SHORT_PROMPT',
        );
      }

      log("Generating image with style: $imageAIStyle");

      Uint8List image = await _ai.generateImage(
        prompt: prompt.trim(),
        apiKey: Env.stabilityApiKey,
        imageAIStyle: imageAIStyle,
      );

      if (image.isEmpty) {
        throw AiServiceException(
          ErrorMessages.emptyResponse,
          code: 'EMPTY_IMAGE',
        );
      }

      log("Image generated successfully: ${image.length} bytes");
      return image;
    } on AiServiceException {
      rethrow;
    } on SocketException catch (e) {
      throw AiServiceException(
        ErrorMessages.networkError,
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    } catch (e) {
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

      if (errorString.contains('content') || errorString.contains('nsfw')) {
        throw AiServiceException(
          ErrorMessages.contentFiltered,
          code: 'CONTENT_FILTERED',
          originalError: e,
        );
      }

      throw AiServiceException(
        ErrorMessages.imageProcessingError,
        code: 'IMAGE_ERROR',
        originalError: e,
      );
    }
  }
}
