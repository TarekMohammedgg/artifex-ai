import 'dart:developer';
import 'package:artifex_ai/core/env.dart';
import 'package:artifex_ai/firebase_options.dart';
import 'package:artifex_ai/screens/home_screen.dart';
import 'package:artifex_ai/theme/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    log(e.toString());
  }

  // Initialize Gemini with API key from environment
  Gemini.init(apiKey: Env.geminiApiKey);

  runApp(const ChatAiApp());
}

class ChatAiApp extends StatelessWidget {
  const ChatAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Will switch based on system setting
      debugShowCheckedModeBanner: false,
      title: 'Artifex AI',
      home: HomeScreen(),
    );
  }
}
