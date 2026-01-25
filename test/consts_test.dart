import 'package:artifex_ai/consts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiConfig', () {
    test('defaultModel is set correctly', () {
      expect(AiConfig.defaultModel, equals('gemini-2.5-flash'));
    });

    test('maxPromptLength is reasonable', () {
      expect(AiConfig.maxPromptLength, greaterThan(1000));
      expect(AiConfig.maxPromptLength, equals(30000));
    });

    test('minPromptLength is at least 1', () {
      expect(AiConfig.minPromptLength, greaterThanOrEqualTo(1));
    });
  });

  group('ValidationMessages', () {
    test('all validation messages are non-empty strings', () {
      expect(ValidationMessages.emptyPrompt, isNotEmpty);
      expect(ValidationMessages.promptTooLong, isNotEmpty);
      expect(ValidationMessages.promptTooShort, isNotEmpty);
      expect(ValidationMessages.noImageSelected, isNotEmpty);
      expect(ValidationMessages.invalidImageFormat, isNotEmpty);
    });
  });

  group('artifexGradient', () {
    test('gradient has correct number of colors', () {
      expect(artifexGradient.colors.length, equals(3));
    });

    test('gradient has valid color values', () {
      for (final color in artifexGradient.colors) {
        expect(color.value, isNonZero);
      }
    });
  });
}
