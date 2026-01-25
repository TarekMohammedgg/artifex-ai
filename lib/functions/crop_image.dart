import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CropImage {
  Future<CroppedFile> crop({required XFile file}) async {
    AndroidUiSettings androidUiSettings = AndroidUiSettings(
      toolbarTitle: "Crop Image",
      toolbarColor: Colors.black,
      toolbarWidgetColor: Colors.white,
      initAspectRatio: CropAspectRatioPreset.original,
      lockAspectRatio: false,
      cropStyle: CropStyle.rectangle,
      aspectRatioPresets: [
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
      ],
    );

    final croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,

      uiSettings: [androidUiSettings],
      compressQuality: 100,
    );

    if (croppedImage != null) {
      return croppedImage;
    } else {
      return CroppedFile(file.path);
    }
  }
}
