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
  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("Remove BG")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _imageFile = await getImage(ImageSource.gallery);
          setState(() {});
        },
        child: Icon(Icons.image),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_imageFile != null)
            Stack(
              children: [
                GestureDetector(
                  onTap: () async {
                    CroppedFile? croppedImage = await CropImage().crop(
                      file: _imageFile!,
                    );
                    if (!mounted) return;

                    setState(() {
                      _imageFile = XFile(croppedImage.path);
                    });
                  },
                  child: InteractiveViewer(
                    child: Image.file(
                      File(_imageFile!.path),
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: () async {
                      try {
                        if (_imageFile == null) return;
                        await Gal.putImage(_imageFile!.path);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("✅Downloaded")));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("❌ Faild to download")),
                        );
                      }
                    },
                    icon: Icon(Icons.download),
                  ),
                ),
              ],
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  final file = await RemoveBgService().removeBgApi(
                    _imageFile!.path,
                  );
                  _imageFile = XFile(file.path);
                  isLoading = false;
                  setState(() {});
                },
                child: isLoading
                    ? CircularProgressIndicator(padding: EdgeInsets.all(10))
                    : Text(
                        "remove BG",
                        style: TextStyle(color: theme.inversePrimary),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
