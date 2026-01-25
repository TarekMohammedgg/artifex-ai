import 'dart:developer';

/// Custom exception for AI service errors
class AiServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AiServiceException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'AiServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Result wrapper for handling success/error states
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data) : error = null, isSuccess = true;

  Result.failure(this.error) : data = null, isSuccess = false;

  /// Execute a function and catch errors
  static Future<Result<T>> guard<T>(Future<T> Function() fn) async {
    try {
      final data = await fn();
      return Result.success(data);
    } on AiServiceException catch (e) {
      log('AiServiceException: ${e.message}', error: e.originalError);
      return Result.failure(e.message);
    } catch (e, stackTrace) {
      log('Unexpected error: $e', error: e, stackTrace: stackTrace);
      return Result.failure('An unexpected error occurred. Please try again.');
    }
  }
}

/// Error messages for different scenarios
class ErrorMessages {
  static const String networkError =
      'Network error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String invalidApiKey =
      'Invalid API key. Please check your configuration.';
  static const String rateLimitExceeded =
      'Rate limit exceeded. Please wait a moment.';
  static const String contentFiltered =
      'Content was filtered by safety settings.';
  static const String timeout = 'Request timed out. Please try again.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String emptyResponse =
      'Received empty response. Please try again.';
  static const String imageProcessingError =
      'Error processing image. Please try a different image.';
}
