import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:artifex_ai/functions/color_filters.dart';
import 'package:artifex_ai/functions/tempfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class FilterImageScreen extends StatefulWidget {
  const FilterImageScreen({super.key});

  @override
  State<FilterImageScreen> createState() => _FilterImageScreenState();
}

class _FilterImageScreenState extends State<FilterImageScreen> {
  ColorFilter currentFilter = ColorFilters.none;
  XFile? imageFile;
  bool hasImage = false;
  final GlobalKey _globalKey = GlobalKey();
  final filters = {
    "Original": ColorFilters.none,
    "Greyscale": ColorFilters.greyscale,
    "Sepia": ColorFilters.sepia,
    "Invert": ColorFilters.invert,
    "Vintage": ColorFilters.vintage,
    "High Contrast": ColorFilters.highContrast,
    "Brightness +": ColorFilters.brightnessUp,
    "Brightness -": ColorFilters.brightnessDown,
    "Saturated": ColorFilters.saturated,
    "Desaturated": ColorFilters.desaturated,
    "Blue Tone": ColorFilters.blueTone,
    "Green Tone": ColorFilters.greenTone,
    "Red Tone": ColorFilters.redTone,
    "Hue Rotate 45°": ColorFilters.hueRotate45,
    "Warm": ColorFilters.warm,
    "Cool": ColorFilters.cool,
    "Polaroid": ColorFilters.polaroid,
  };

  Future<XFile?> getImage(ImageSource source) async {
    final picker = ImagePicker();
    return await picker.pickImage(source: source);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Color Filter Preview")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          imageFile = await getImage(ImageSource.gallery);
          hasImage = true;
          setState(() {});
        },
        child: const Icon(Icons.image),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: ColorFiltered(
                  colorFilter: currentFilter,
                  child: hasImage
                      ? Image.file(
                          File(imageFile!.path),
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          "assets/normal_image.png",
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                ),
              ),

              Positioned(
                right: 0,
                child: imageFile != null
                    ? IconButton(
                        onPressed: _saveFilteredImage,
                        icon: const Icon(Icons.download, color: Colors.purple),
                      )
                    : Container(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: filters.entries.map((entry) {
                final name = entry.key;
                final filter = entry.value;
                final isSelected = currentFilter == filter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.purple : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: ColorFiltered(
                            colorFilter: filter,
                            child: hasImage
                                ? Image.file(
                                    File(imageFile!.path),
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "assets/normal_image.png",
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.purple : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),
        ],
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
