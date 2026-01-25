import 'package:artifex_ai/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessageShimmer', () {
    testWidgets('renders correctly for AI message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatMessageShimmer(isUserMessage: false)),
        ),
      );

      expect(find.byType(ChatMessageShimmer), findsOneWidget);
    });

    testWidgets('renders correctly for user message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatMessageShimmer(isUserMessage: true)),
        ),
      );

      expect(find.byType(ChatMessageShimmer), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: ChatMessageShimmer(isUserMessage: false)),
        ),
      );

      expect(find.byType(ChatMessageShimmer), findsOneWidget);
    });
  });

  group('ImageGenerationShimmer', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ImageGenerationShimmer())),
      );

      expect(find.byType(ImageGenerationShimmer), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.text('Generating image...'), findsOneWidget);
    });
  });

  group('FeatureCardShimmer', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FeatureCardShimmer())),
      );

      expect(find.byType(FeatureCardShimmer), findsOneWidget);
    });
  });

  group('ImageGalleryShimmer', () {
    testWidgets('renders correct number of items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ImageGalleryShimmer(itemCount: 6),
            ),
          ),
        ),
      );

      expect(find.byType(ImageGalleryShimmer), findsOneWidget);
    });

    testWidgets('renders with custom item count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ImageGalleryShimmer(itemCount: 9),
            ),
          ),
        ),
      );

      expect(find.byType(ImageGalleryShimmer), findsOneWidget);
    });
  });
}
