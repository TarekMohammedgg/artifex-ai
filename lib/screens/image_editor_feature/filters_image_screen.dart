import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:artifex_ai/functions/color_filters.dart';
import 'package:artifex_ai/functions/tempfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';

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
    ColorScheme theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Filters"),
        actions: [
          if (imageFile != null)
            IconButton(
              onPressed: _saveFilteredImage,
              icon: const Icon(Icons.download),
              tooltip: "Save to gallery",
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          imageFile = await getImage(ImageSource.gallery);
          setState(() {
            hasImage = imageFile != null;
          });
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
                      child: ColorFiltered(
                        colorFilter: currentFilter,
                        child: Image.file(
                          File(imageFile!.path),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_filter,
                          size: 64,
                          color: theme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Select an image to apply filters",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal filters list
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filters.entries.map((entry) {
                final isSelected = currentFilter == entry.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentFilter = entry.value;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? theme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ColorFiltered(
                              colorFilter: entry.value,
                              child: imageFile != null
                                  ? Image.file(
                                      File(imageFile!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey.shade800,
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white54,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? theme.primary : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),
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

      await Gal.putImage(file.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Filtered image saved to gallery!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to save filtered image: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
