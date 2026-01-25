import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<File> writeBytesToTempFile(Uint8List bytes, {String? name}) async {
  final dir = await getTemporaryDirectory();
  final fileName =
      name ?? 'ai_image_${DateTime.now().millisecondsSinceEpoch}.png';
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}
