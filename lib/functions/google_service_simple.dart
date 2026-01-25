// import 'package:firebase_ai/firebase_ai.dart';

// abstract class GoogleAiService {
//   static Future<String> generateText(String? notes) async {
//     final model = FirebaseAI.googleAI().generativeModel(
//       model: "gemini-2.5-flash",
//     );
//     final prompt = "Answer this question briefly and clearly: $notes";

//     final response = await model.generateContent([Content.text(prompt)]);
//     String result = response.text ?? "try again";
//     return result;
//   }
// }