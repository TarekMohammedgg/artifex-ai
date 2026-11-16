import 'dart:io';

import 'package:artifex_ai/functions/crop_image.dart';
import 'package:artifex_ai/functions/pick_image.dart';
import 'package:artifex_ai/services/remove_bg_service.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class RemovebgImageScreen extends StatefulWidget {
  const RemovebgImageScreen({super.key});

  @override
  State<RemovebgImageScreen> createState() => _RemovebgImageScreenState();
}

class _RemovebgImageScreenState extends State<RemovebgImageScreen> {
  XFile? _imageFile;
  bool isLoading = false;

  Future<void> _saveImage() async {
    if (_imageFile == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Gal.putImage(_imageFile!.path);
      messenger.showSnackBar(
        const SnackBar(
          content: Text("✅ Saved to gallery!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("❌ Failed to save: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Background Eraser"),
        actions: [
          if (_imageFile != null)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: "Save to gallery",
              onPressed: _saveImage,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final picked = await getImage(ImageSource.gallery);
          if (picked != null && mounted) {
            setState(() {
              _imageFile = picked;
            });
          }
        },
        child: const Icon(Icons.photo_library),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _imageFile != null
                  ? GestureDetector(
                      onTap: () async {
                        CroppedFile croppedImage = await CropImage().crop(
                          file: _imageFile!,
                        );
                        if (mounted) {
                          setState(() {
                            _imageFile = XFile(croppedImage.path);
                          });
                        }
                      },
                      child: InteractiveViewer(
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.layers_clear,
                          size: 64,
                          color: theme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Select an image to remove background",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 24, right: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => isLoading = true);
                          try {
                            final file = await RemoveBgService().removeBgApi(
                              _imageFile!.path,
                            );
                            if (mounted) {
                              setState(() {
                                _imageFile = XFile(file.path);
                                isLoading = false;
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => isLoading = false);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text("Error: $e"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high),
                  label: Text(isLoading ? "Processing..." : "Remove Background"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
