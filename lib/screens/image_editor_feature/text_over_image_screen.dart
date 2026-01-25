import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:artifex_ai/functions/tempfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:artifex_ai/functions/pick_image.dart';

class TextOverImageScreen extends StatefulWidget {
  const TextOverImageScreen({super.key});

  @override
  State<TextOverImageScreen> createState() => _TextOverImageScreenState();
}

class _TextOverImageScreenState extends State<TextOverImageScreen> {
  XFile? imageFile;
  Offset textPosition = const Offset(100, 100);
  final textController = TextEditingController();
  bool isSelected = false;
  final GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Over Image"),
        actions: [
          IconButton(onPressed: _saveFilteredImage, icon: Icon(Icons.download)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          imageFile = await getImage(ImageSource.gallery);
          setState(() {});
        },
        child: const Icon(Icons.image),
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTap: () {
            setState(() => isSelected = true);
          },
          onTap: () {
            setState(() => isSelected = false);
          },
          onPanUpdate: (details) {
            setState(() {
              textPosition += details.delta;
            });
          },
          child: Container(
            width: double.infinity,
            height: 400,
            child: RepaintBoundary(
              key: _globalKey,
              child: Stack(
                children: [
                  Center(
                    child: imageFile != null
                        ? Image.file(File(imageFile!.path), fit: BoxFit.contain)
                        : Image.asset(
                            "assets/normal_image.png",

                            fit: BoxFit.contain,
                          ),
                  ),
                  Positioned(
                    left: textPosition.dx,
                    top: textPosition.dy,
                    child: isSelected
                        ? SizedBox(
                            width: 200,
                            child: TextField(
                              controller: textController,
                              autofocus: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                              onSubmitted: (_) {
                                setState(() => isSelected = false);
                              },
                            ),
                          )
                        : Text(
                            textController.text.isEmpty
                                ? "Tarek"
                                : textController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveFilteredImage() async {
    try {
      if (imageFile == null) return;

      final boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final file = await writeBytesToTempFile(pngBytes);

      // final dir = await getTemporaryDirectory();
      // final path =
      //     '${dir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.png';
      // final file = File(path);
      // await file.writeAsBytes(pngBytes);

      await Gal.putImage(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Filtered image saved to gallery!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save filtered image: $e")),
      );
    }
  }
}
