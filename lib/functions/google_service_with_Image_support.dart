// import 'dart:io';

// import 'package:ai_chatbot/firebase_options.dart';
// import 'package:firebase_ai/firebase_ai.dart';
// import 'package:firebase_core/firebase_core.dart';

// firebase_function() async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Initialize the Gemini Developer API backend service
//   // Create a `GenerativeModel` instance with a Gemini model that supports image output
//   final model = FirebaseAI.googleAI().generativeModel(
//     model: 'gemini-2.5-flash-image',
//     // Configure the model to respond with text and images (required)
//     generationConfig: GenerationConfig(
//       responseModalities: [ResponseModalities.text, ResponseModalities.image],
//     ),
//   );

//   // Prepare an image for the model to edit
//   final image = await File('scones.jpg').readAsBytes();
//   final imagePart = InlineDataPart('image/jpeg', image);

//   // Provide a text prompt instructing the model to edit the image
//   final prompt = TextPart("Edit this image to make it look like a cartoon");

//   // To edit the image, call `generateContent` with the image and text input
//   final response = await model.generateContent([
//     Content.multi([prompt, imagePart]),
//   ]);

//   // Handle the generated image
//   if (response.inlineDataParts.isNotEmpty) {
//     final imageBytes = response.inlineDataParts;
//     // Process the image
//   } else {
//     // Handle the case where no images were generated
//     print('Error: No images were generated.');
//   }
// }