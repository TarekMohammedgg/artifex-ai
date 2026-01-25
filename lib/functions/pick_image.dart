import 'package:image_picker/image_picker.dart';

Future<XFile?> getImage(ImageSource imageSource) async {
  final pickedImage = await ImagePicker().pickImage(source: imageSource);
  if (pickedImage != null) {
    final imageFile = pickedImage;
    return imageFile;
  }
}
