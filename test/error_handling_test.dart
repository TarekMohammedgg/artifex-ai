import 'package:artifex_ai/core/error_handling.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiServiceException', () {
    test('creates exception with message only', () {
      final exception = AiServiceException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
    });

    test('creates exception with message and code', () {
      final exception = AiServiceException('Test error', code: 'TEST_CODE');
      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('TEST_CODE'));
    });

    test('creates exception with all parameters', () {
      final originalError = Exception('Original');
      final exception = AiServiceException(
        'Test error',
        code: 'TEST_CODE',
        originalError: originalError,
      );
      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('TEST_CODE'));
      expect(exception.originalError, equals(originalError));
    });

    test('toString formats correctly without code', () {
      final exception = AiServiceException('Test error');
      expect(exception.toString(), equals('AiServiceException: Test error'));
    });

    test('toString formats correctly with code', () {
      final exception = AiServiceException('Test error', code: 'TEST_CODE');
      expect(
        exception.toString(),
        equals('AiServiceException: Test error (Code: TEST_CODE)'),
      );
    });
  });

  group('Result', () {
    test('success result has data and isSuccess true', () {
      final result = Result.success('test data');
      expect(result.data, equals('test data'));
      expect(result.isSuccess, isTrue);
      expect(result.error, isNull);
    });

    test('failure result has error and isSuccess false', () {
      final result = Result<String>.failure('error message');
      expect(result.error, equals('error message'));
      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
    });

    test('guard catches AiServiceException', () async {
      final result = await Result.guard<String>(() async {
        throw AiServiceException('AI error');
      });

      expect(result.isSuccess, isFalse);
      expect(result.error, equals('AI error'));
    });

    test('guard catches general exceptions', () async {
      final result = await Result.guard<String>(() async {
        throw Exception('General error');
      });

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('guard returns success for successful function', () async {
      final result = await Result.guard<String>(() async {
        return 'success';
      });

      expect(result.isSuccess, isTrue);
      expect(result.data, equals('success'));
    });
  });

  group('ErrorMessages', () {
    test('contains all required error messages', () {
      expect(ErrorMessages.networkError, isNotEmpty);
      expect(ErrorMessages.serverError, isNotEmpty);
      expect(ErrorMessages.invalidApiKey, isNotEmpty);
      expect(ErrorMessages.rateLimitExceeded, isNotEmpty);
      expect(ErrorMessages.contentFiltered, isNotEmpty);
      expect(ErrorMessages.timeout, isNotEmpty);
      expect(ErrorMessages.unknownError, isNotEmpty);
      expect(ErrorMessages.emptyResponse, isNotEmpty);
      expect(ErrorMessages.imageProcessingError, isNotEmpty);
    });
  });
}
