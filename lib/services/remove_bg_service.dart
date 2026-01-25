import 'dart:io';
import 'package:artifex_ai/core/env.dart';
import 'package:artifex_ai/core/error_handling.dart';
import 'package:artifex_ai/functions/tempfile.dart';
import 'package:http/http.dart' as http;

class RemoveBgService {
  /// Removes background with proper error handling
  /// Returns a Result containing either the processed image file or an error message
  Future<Result<File>> removeBgApiSafe(String imagePath) async {
    return Result.guard(() => removeBgApi(imagePath));
  }

  /// Removes background from an image using Remove.bg API
  /// Throws AiServiceException on error
  Future<File> removeBgApi(String imagePath) async {
    try {
      // Validate input
      if (imagePath.isEmpty) {
        throw AiServiceException('No image path provided', code: 'EMPTY_PATH');
      }

      final file = File(imagePath);
      if (!file.existsSync()) {
        throw AiServiceException(
          'Image file not found',
          code: 'FILE_NOT_FOUND',
        );
      }

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://api.remove.bg/v1.0/removebg"),
      );

      request.files.add(
        await http.MultipartFile.fromPath("image_file", imagePath),
      );

      request.headers.addAll({"X-Api-Key": Env.removebgApiKey});

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw AiServiceException(ErrorMessages.timeout, code: 'TIMEOUT');
        },
      );

      if (response.statusCode == 200) {
        http.Response imageRes = await http.Response.fromStream(response);
        File imageFile = await writeBytesToTempFile(imageRes.bodyBytes);
        return imageFile;
      } else if (response.statusCode == 401) {
        throw AiServiceException(
          ErrorMessages.invalidApiKey,
          code: 'INVALID_API_KEY',
        );
      } else if (response.statusCode == 402) {
        throw AiServiceException(
          'API credits exhausted. Please check your Remove.bg account.',
          code: 'CREDITS_EXHAUSTED',
        );
      } else if (response.statusCode == 429) {
        throw AiServiceException(
          ErrorMessages.rateLimitExceeded,
          code: 'RATE_LIMIT',
        );
      } else {
        throw AiServiceException(
          'Error removing background (Code: ${response.statusCode})',
          code: 'API_ERROR',
        );
      }
    } on AiServiceException {
      rethrow;
    } on SocketException catch (e) {
      throw AiServiceException(
        ErrorMessages.networkError,
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    } catch (e) {
      throw AiServiceException(
        ErrorMessages.imageProcessingError,
        code: 'PROCESSING_ERROR',
        originalError: e,
      );
    }
  }
}
