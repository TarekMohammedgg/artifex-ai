import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:artifex_ai/functions/color_filters.dart';
import 'package:artifex_ai/functions/crop_image.dart';
import 'package:artifex_ai/functions/pick_image.dart';
import 'package:artifex_ai/functions/tempfile.dart';
import 'package:artifex_ai/screens/image_editor_feature/text_recognition_screen.dart';
import 'package:artifex_ai/services/remove_bg_service.dart';
import 'package:artifex_ai/widgets/filter_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageStudioScreen extends StatefulWidget {
  const ImageStudioScreen({super.key, this.source = ImageSource.camera});
  final ImageSource source;
  @override
  State<ImageStudioScreen> createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends State<ImageStudioScreen> {
  ColorFilter currentFilter = ColorFilters.none;
  bool isLoading = false;
  XFile? imageFile;
  XFile? originalFile;
  EditMode currentMode = EditMode.none;
  Offset textPosition = const Offset(100, 100);
  final textController = TextEditingController();
  bool isSelected = false;
  GlobalKey globalKey = GlobalKey();
  SaveState saveState = SaveState.idle;
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

  Color currentColor = Colors.white;
  bool colorSelected = false;
  List<Color> myColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
  ];
  double textSize = 16;
  bool hasImage = false;
  double value = 0;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    XFile? file;
    if (widget.source == ImageSource.camera) {
      file = await getImage(ImageSource.camera);
    } else {
      file = await getImage(ImageSource.gallery);
    }
    if (mounted) {
      setState(() {
        imageFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    if (imageFile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.secondary),
        ),
        title: Text("Edit", style: TextStyle(color: theme.secondary)),
        actions: [
          IconButton(
            onPressed: () async {
              if (saveState == SaveState.loading) return;
              setState(() => saveState = SaveState.loading);
              bool result = await saveImage();

              if (result) {
                setState(() {
                  saveState = SaveState.done;
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => saveState = SaveState.idle);
                  });
                });
              } else {
                setState(() {
                  saveState = SaveState.failed;
                });
              }
            },
            icon: Builder(
              builder: (_) {
                switch (saveState) {
                  case SaveState.loading:
                    return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  case SaveState.done:
                    return Icon(Icons.check, color: theme.secondary);
                  case SaveState.failed:
                    return Icon(Icons.info, color: theme.secondary);
                  case SaveState.idle:
                    return Icon(Icons.download, color: theme.secondary);
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade900,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    key: globalKey,
                    child: GestureDetector(
                      onDoubleTap: () => setState(() => isSelected = true),
                      onTap: () => setState(() => isSelected = false),
                      onPanUpdate: (details) {
                        if (currentMode == EditMode.text) {
                          setState(() => textPosition += details.delta);
                        }
                      },
                      child: ClipRRect(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: currentFilter,
                              child: Image.file(
                                File(imageFile!.path),
                                fit: BoxFit.fill,
                              ),
                            ),
                            BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: value,
                                sigmaY: value,
                              ),
                              child: Container(color: Colors.transparent),
                            ),
                            if (currentMode == EditMode.text ||
                                textController.text.isNotEmpty)
                              Positioned(
                                left: textPosition.dx == 0
                                    ? (MediaQuery.of(context).size.width / 2) -
                                          60
                                    : textPosition.dx,
                                top: textPosition.dy == 0
                                    ? (MediaQuery.of(context).size.height / 2) -
                                          20
                                    : textPosition.dy,
                                child: Text(
                                  textController.text.isEmpty
                                      ? "Type"
                                      : textController.text,
                                  style: TextStyle(
                                    color: currentColor,
                                    fontSize: textSize,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: buildBottomSection(),
                ),
              ],
            ),
          ),

          if (isSelected)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 5,
                      width: 60,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    TextField(
                      controller: textController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: "Type here...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) =>
                          setState(() => textController.text = value),
                      onSubmitted: (_) => setState(() => isSelected = false),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildBottomSection() {
    switch (currentMode) {
      case EditMode.filter:
        return filterFeature();
      case EditMode.removeBG:
        return removeBGFeature();
      case EditMode.text:
        return textFeature();
      case EditMode.blur:
        return blurFeature();
      default:
        return buildMainTools();
    }
  }

  Widget removeBGFeature() {
    return Column(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
                originalFile = imageFile;
              });
              final file = await RemoveBgService().removeBgApi(imageFile!.path);
              imageFile = XFile(file.path);
              isLoading = false;
              setState(() {});
            },
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("Remove BG"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (originalFile != null) imageFile = originalFile;
                  currentMode = EditMode.none;
                });
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => setState(() => currentMode = EditMode.none),
              child: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }

  Widget filterFeature() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.entries.map((entry) {
              final name = entry.key;
              final filter = entry.value;
              final selected = currentFilter == filter;
              return GestureDetector(
                onTap: () => setState(() => currentFilter = filter),
                child: FilterTile(
                  name: name,
                  imageFile: File(imageFile!.path),
                  filter: filter,
                  isSelected: selected,
                ),
              );
            }).toList(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  currentMode = EditMode.none;
                  currentFilter = ColorFilters.none;
                });
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => setState(() => currentMode = EditMode.none),
              child: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }

  Widget textFeature() {
    return Column(
      children: [
        Slider(
          value: textSize,
          min: 10,
          max: 100,
          divisions: 100,
          label: textSize.round().toString(),
          onChanged: (v) => setState(() => textSize = v),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: myColors.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => setState(() => currentColor = myColors[index]),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: currentColor == myColors[index]
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    color: myColors[index],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  currentMode = EditMode.none;
                  textController.text = "";
                });
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => setState(() => currentMode = EditMode.none),
              child: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }

  Widget blurFeature() {
    return Column(
      children: [
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 10,
          label: value.round().toString(),
          onChanged: (v) => setState(() => value = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  currentMode = EditMode.none;
                  value = 0;
                });
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => setState(() => currentMode = EditMode.none),
              child: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMainTools() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          featureItem(
            Icons.bubble_chart_outlined,
            "Filter",
            () => setState(() => currentMode = EditMode.filter),
          ),
          featureItem(
            Icons.texture_outlined,
            "Remove BG",
            () => setState(() => currentMode = EditMode.removeBG),
          ),
          featureItem(
            Icons.text_fields_outlined,
            "Text",
            () => setState(() => currentMode = EditMode.text),
          ),
          featureItem(
            Icons.blur_on,
            "Blur",
            () => setState(() => currentMode = EditMode.blur),
          ),
          featureItem(Icons.translate, "Text Recognition", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TextRecognitionScreen(imageFile: imageFile!),
              ),
            );
          }),
          featureItem(Icons.crop, "Crop", () async {
            CroppedFile? croppedImage = await CropImage().crop(
              file: imageFile!,
            );
            if (!mounted) return;
            setState(() => imageFile = XFile(croppedImage.path));
          }),
        ],
      ),
    );
  }

  Widget featureItem(IconData icon, String text, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xff272727),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> saveImage() async {
    bool state = false;
    try {
      if (imageFile == null) {
        state = false;
        return false;
      }
      ;
      final boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final file = await writeBytesToTempFile(pngBytes);
      await Gal.putImage(file.path);

      state = true;
      return state;
    } catch (e) {
      log("save error: ${e.toString()}");

      state = false;
      return state;
    }
  }
}

enum EditMode { none, filter, removeBG, text, blur, crop }

enum SaveState { idle, loading, done, failed }
