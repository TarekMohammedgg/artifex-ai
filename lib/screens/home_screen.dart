import 'dart:ui';
import 'package:artifex_ai/consts.dart';
import 'package:artifex_ai/screens/image_studio_screen.dart';
import 'package:artifex_ai/screens/image_to_text_chat_screen.dart';
import 'package:artifex_ai/screens/settings_screen.dart';
import 'package:artifex_ai/screens/text_to_image_screen.dart';
import 'package:artifex_ai/screens/text_to_text_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AssetEntity> images = [];

  Future<void> fetchAssets() async {
    images = await PhotoManager.getAssetListRange(
      start: 0,
      end: 20,
      type: RequestType.image,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // CustomContainer(icon: Icons.edit),
                  CustomContainer(
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImageStudioScreen(
                            source: ImageSource.camera,
                          ),
                        ),
                      );
                    },
                    title: "Camera",
                    icon: Icons.camera_alt_outlined,
                  ),
                  CustomItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImageStudioScreen(
                            source: ImageSource.gallery,
                          ),
                        ),
                      );
                    },
                    title: "Gallery",
                    icon: Icons.photo_library_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: 50,
                child: Divider(color: Theme.of(context).colorScheme.primary),
              ),

              // Animated Banner with AspectRatio
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            "assets/ai_image.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.6,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: artifexGradient,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Create with ",
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              "generative AI",
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Try out the latest innovations.",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      CustomPositionedButton(
                        icon: Icons.chat_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TextToTextScreen(),
                            ),
                          );
                        },
                        title: "Chat",
                        left: 10,
                        bottom: 10,
                      ),
                      CustomPositionedButton(
                        icon: Icons.text_fields_sharp,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImageToTextScreen(),
                            ),
                          );
                        },
                        title: "Describe",
                        right: 120,
                        bottom: 10,
                      ),
                      CustomPositionedButton(
                        icon: Icons.stars,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TextToImageScreen(),
                            ),
                          );
                        },
                        title: "Imagine",
                        right: 10,
                        bottom: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomPositionedButton extends StatelessWidget {
  const CustomPositionedButton({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.title,
    required this.onTap,
    required this.icon,
  });
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final String title;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      right: right,
      bottom: bottom,
      left: left,
      top: top,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: colorScheme.surface.withValues(alpha: 0.6),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomItem extends StatelessWidget {
  const CustomItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
  });
  final VoidCallback? onTap;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Icon(
                icon,
                size: 32,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}

class CustomContainer extends StatelessWidget {
  const CustomContainer({super.key, required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
