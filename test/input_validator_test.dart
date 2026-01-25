import 'package:artifex_ai/consts.dart';
import 'package:artifex_ai/core/input_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputValidator', () {
    group('validatePrompt', () {
      test('returns error for null input', () {
        final result = InputValidator.validatePrompt(null);
        expect(result, equals(ValidationMessages.emptyPrompt));
      });

      test('returns error for empty string', () {
        final result = InputValidator.validatePrompt('');
        expect(result, equals(ValidationMessages.emptyPrompt));
      });

      test('returns error for whitespace only', () {
        final result = InputValidator.validatePrompt('   ');
        expect(result, equals(ValidationMessages.emptyPrompt));
      });

      test('returns null for valid input', () {
        final result = InputValidator.validatePrompt('Hello, how are you?');
        expect(result, isNull);
      });

      test('returns null for minimum valid length', () {
        final result = InputValidator.validatePrompt('H');
        expect(result, isNull);
      });

      test('returns error for input exceeding max length', () {
        final longInput = 'a' * (AiConfig.maxPromptLength + 1);
        final result = InputValidator.validatePrompt(longInput);
        expect(result, equals(ValidationMessages.promptTooLong));
      });

      test('returns null for input at max length', () {
        final maxInput = 'a' * AiConfig.maxPromptLength;
        final result = InputValidator.validatePrompt(maxInput);
        expect(result, isNull);
      });
    });

    group('validateImagePrompt', () {
      test('returns error for empty prompt', () {
        final result = InputValidator.validateImagePrompt('');
        expect(result, equals(ValidationMessages.emptyPrompt));
      });

      test('returns error for too short prompt', () {
        final result = InputValidator.validateImagePrompt('ab');
        expect(result, isNotNull);
      });

      test('returns null for valid image prompt', () {
        final result = InputValidator.validateImagePrompt(
          'A beautiful sunset over mountains',
        );
        expect(result, isNull);
      });
    });

    group('validateImages', () {
      test('returns null for null input (images are optional)', () {
        final result = InputValidator.validateImages(null);
        expect(result, isNull);
      });

      test('returns null for empty list', () {
        final result = InputValidator.validateImages([]);
        expect(result, isNull);
      });

      test('returns error when list has only null/empty paths', () {
        final result = InputValidator.validateImages([null, '', null]);
        expect(result, equals(ValidationMessages.noImageSelected));
      });

      test('returns null for valid image paths', () {
        final result = InputValidator.validateImages([
          '/path/to/image1.jpg',
          '/path/to/image2.png',
        ]);
        expect(result, isNull);
      });
    });

    group('sanitize', () {
      test('trims whitespace', () {
        final result = InputValidator.sanitize('  hello  ');
        expect(result, equals('hello'));
      });

      test('replaces multiple spaces with single space', () {
        final result = InputValidator.sanitize('hello    world');
        expect(result, equals('hello world'));
      });

      test('handles tabs and newlines', () {
        final result = InputValidator.sanitize('hello\t\nworld');
        expect(result, equals('hello world'));
      });
    });
  });
}
