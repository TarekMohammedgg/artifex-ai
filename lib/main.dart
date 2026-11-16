import 'dart:developer';
import 'package:artifex_ai/firebase_options.dart';
import 'package:artifex_ai/screens/home_screen.dart';
import 'package:artifex_ai/theme/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash screen so it is visible and centered
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase safely without blocking on network/AppCheck
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    log('Firebase init note: $error', error: error, stackTrace: stackTrace);
  }

  // Load environment variables (e.g., Remove.bg API key)
  try {
    await dotenv.load(fileName: '.env');
  } catch (error, stackTrace) {
    log('Could not load .env file: $error', error: error, stackTrace: stackTrace);
  }

  runApp(const ArtifexPhotoStudioApp());

  // Remove splash screen smoothly after initial presentation
  Future.delayed(const Duration(milliseconds: 1500), () {
    FlutterNativeSplash.remove();
  });
}

class ArtifexPhotoStudioApp extends StatelessWidget {
  const ArtifexPhotoStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Will switch based on system setting
      debugShowCheckedModeBanner: false,
      title: 'Artifex Photo Editor',
      home: HomeScreen(),
    );
  }
}
