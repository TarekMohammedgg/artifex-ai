import 'dart:io';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:artifex_ai/core/error_handling.dart';
import 'package:artifex_ai/core/input_validator.dart';
import 'package:artifex_ai/services/stability_ai.dart';
import 'package:artifex_ai/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stability_image_generation/stability_image_generation.dart';

class TextToImageScreen extends StatefulWidget {
  const TextToImageScreen({super.key});

  @override
  State<TextToImageScreen> createState() => _TextToImageScreenState();
}

class _TextToImageScreenState extends State<TextToImageScreen> {
  final describeController = TextEditingController();
  Uint8List? image;
  bool isLoading = false;
  bool isSaving = false;
  ImageAIStyle style = ImageAIStyle.noStyle;
  String? errorMessage;

  Future<File> writeBytesToTempFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${describeController.text}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _downloadImage() async {
    if (image == null) return;
    setState(() => isSaving = true);

    try {
      final file = await writeBytesToTempFile(image!);
      await Gal.putImage(file.path);
      _showSuccess("Image saved to gallery");
    } catch (e) {
      _showError("Failed to save image: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _generateImage() async {
    FocusScope.of(context).unfocus();

    // Validate input
    final validationError = InputValidator.validateImagePrompt(
      describeController.text,
    );
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      image = null;
    });

    final result = await StabilityAi.generateImageSafe(
      describeController.text.trim(),
      style,
    );

    setState(() {
      isLoading = false;
    });

    if (result.isSuccess && result.data != null) {
      setState(() {
        image = result.data;
        describeController.clear();
      });
    } else {
      setState(() {
        errorMessage = result.error;
      });
      _showError(result.error ?? ErrorMessages.unknownError);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ $message"),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ $message"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    describeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Image Generator"), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Input field with theme-aware colors
                        TextField(
                          controller: describeController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.grey.shade900,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                "Describe the image you want to create...",
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            prefixIcon: Icon(
                              Icons.edit,
                              color: colorScheme.primary,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                        const SizedBox(height: 16),

                        // Style selector
                        Row(
                          children: [
                            Text(
                              "Choose your style",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: ImageAIStyle.values.length,
                            itemBuilder: (context, index) {
                              final s = ImageAIStyle.values[index];
                              final isSelected = style == s;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(s.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => style = s);
                                    }
                                  },
                                  selectedColor: colorScheme.primaryContainer,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Generate button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _generateImage,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: isLoading
                                ? AnimatedTextKit(
                                    pause: const Duration(milliseconds: 900),
                                    repeatForever: true,
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        "Generating...",
                                        speed: const Duration(
                                          milliseconds: 100,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text("Generate Image"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Image display area
                        Expanded(child: _buildImageArea(colorScheme)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageArea(ColorScheme colorScheme) {
    if (isLoading) {
      return const ImageGenerationShimmer();
    }

    if (errorMessage != null && image == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateImage,
              child: const Text("Try Again"),
            ),
          ],
        ),
      );
    }

    if (image != null) {
      return Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(image!, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : _downloadImage,
              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(isSaving ? "Saving..." : "Download Image"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    // Empty state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "Describe your vision above\nand tap Generate",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
