import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:artifex_ai/functions/pick_image.dart';
import 'package:artifex_ai/functions/tempfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';

class BlurImageScreen extends StatefulWidget {
  const BlurImageScreen({super.key});

  @override
  State<BlurImageScreen> createState() => _BlurImageScreenState();
}

class _BlurImageScreenState extends State<BlurImageScreen> {
  double value = 15;
  XFile? imageFile;
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _saveBlurredImage() async {
    try {
      if (imageFile == null) return;

      final boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final file = await writeBytesToTempFile(pngBytes);

      await Gal.putImage(file.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Blurred image saved to gallery!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to save image: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blur & Focus"),
        actions: [
          if (imageFile != null)
            IconButton(
              onPressed: _saveBlurredImage,
              icon: const Icon(Icons.download),
              tooltip: "Save to gallery",
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final picked = await getImage(ImageSource.gallery);
          if (picked != null && mounted) {
            setState(() {
              imageFile = picked;
            });
          }
        },
        child: const Icon(Icons.photo_library),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: imageFile != null
                  ? RepaintBoundary(
                      key: _globalKey,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.file(File(imageFile!.path), fit: BoxFit.contain),
                          ClipRect(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: value,
                                sigmaY: value,
                              ),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.blur_on,
                          size: 64,
                          color: theme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Select an image to adjust blur depth",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),
          ),
          if (imageFile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.black26,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Blur Intensity",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("${value.round()} px"),
                    ],
                  ),
                  Slider(
                    value: value,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    label: "${value.round()}",
                    onChanged: (newValue) {
                      setState(() {
                        value = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
