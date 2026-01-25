import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key, required this.imageFile});
  final XFile imageFile;

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  bool isLoading = false;
  String text = "no text yet ";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Text Recognition"),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(
              File(widget.imageFile.path),
              height: MediaQuery.sizeOf(context).height * 0.7,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final file = File(widget.imageFile.path);
                  text = await extractText(file);
                  setState(() {
                    isLoading = false;
                  });
                },
                child: isLoading
                    ? CircularProgressIndicator(padding: EdgeInsets.all(10))
                    : Text(
                        "recognize text",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 10),
            SelectableText(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Future<String> extractText(File file) async {
    final textRecogniser = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText = await textRecogniser.processImage(
      inputImage,
    );

    final String text = recognizedText.text;
    return text;
  }
}
