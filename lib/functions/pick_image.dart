import 'package:image_picker/image_picker.dart';

Future<XFile?> getImage(ImageSource imageSource) async {
  return await ImagePicker().pickImage(source: imageSource);
}
