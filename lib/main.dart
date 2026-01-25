import 'package:artifex_ai/core/env.dart';
import 'package:artifex_ai/firebase_options.dart';
import 'package:artifex_ai/screens/home_screen.dart';
import 'package:artifex_ai/theme/toggle_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Gemini with API key from environment
  Gemini.init(apiKey: Env.geminiApiKey);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const ChatAiApp(),
    ),
  );
}

class ChatAiApp extends StatelessWidget {
  const ChatAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artifex AI',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: HomeScreen(),
    );
  }
}
