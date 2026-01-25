import 'dart:io';
import 'dart:ui';

import 'package:artifex_ai/functions/pick_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BlurImageScreen extends StatefulWidget {
  @override
  State<BlurImageScreen> createState() => _BlurImageScreenState();
}

class _BlurImageScreenState extends State<BlurImageScreen> {
  double value = 50;
  XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Blur Image")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          imageFile = await getImage(ImageSource.gallery);
          setState(() {});
        },
        child: Icon(Icons.image),
      ),
      body: Stack(
        children: [
          imageFile != null
              ? Image.file(File(imageFile!.path), fit: BoxFit.cover)
              : Container(),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 100,
            left: 0,
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              label: value.round().toString(),
              onChanged: (newValue) {
                setState(() {
                  value = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
