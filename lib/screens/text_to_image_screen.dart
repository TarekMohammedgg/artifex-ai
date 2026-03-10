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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Image Generator"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Input field with theme-aware colors
              TextField(
                controller: describeController,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Describe the image you want to create...",
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  prefixIcon: Icon(Icons.edit, color: colorScheme.primary),
                  contentPadding: const EdgeInsets.all(16),
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
                child: _BouncyButton(
                  onPressed: isLoading ? null : _generateImage,
                  isLoading: isLoading,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(height: 20),

              // Image display area
              SizedBox(
                height: 350,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: _buildImageArea(colorScheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea(ColorScheme colorScheme) {
    if (isLoading) {
      return const ImageGenerationShimmer(key: ValueKey('loading'));
    }

    if (errorMessage != null && image == null) {
      return Center(
        key: const ValueKey('error'),
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
        key: const ValueKey('loaded'),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Empty state
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            "Describe your vision above\nand tap Generate",
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _BouncyButton extends StatefulWidget {
  const _BouncyButton({
    required this.onPressed,
    required this.isLoading,
    required this.colorScheme,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final ColorScheme colorScheme;

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.onPressed == null
                ? widget.colorScheme.surfaceContainerHighest
                : widget.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (widget.onPressed != null && !_isPressed)
                BoxShadow(
                  color: widget.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(
                  Icons.auto_awesome,
                  color: widget.onPressed == null
                      ? widget.colorScheme.onSurface.withValues(alpha: 0.38)
                      : widget.colorScheme.onPrimary,
                ),
              const SizedBox(width: 8),
              if (widget.isLoading)
                DefaultTextStyle(
                  style: TextStyle(
                    color: widget.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  child: AnimatedTextKit(
                    pause: const Duration(milliseconds: 900),
                    repeatForever: true,
                    animatedTexts: [
                      TyperAnimatedText(
                        "Generating...",
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  "Generate Image",
                  style: TextStyle(
                    color: widget.onPressed == null
                        ? widget.colorScheme.onSurface.withValues(alpha: 0.38)
                        : widget.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
