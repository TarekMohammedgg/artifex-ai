# 🎨 Artifex AI

A feature-rich Flutter AI chatbot application that integrates multiple AI services for conversational AI, image generation, and advanced image editing capabilities.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

## ✨ Features

### 🗣️ AI Chat
- **Text-to-Text Chat**: Conversational AI powered by Google Gemini 2.5 Flash
- **Image-to-Text Chat**: Multi-modal AI that understands images and text together
- **Markdown Support**: AI responses rendered with full markdown formatting
- **Animated Responses**: Smooth typing animations for AI responses

### 🎨 Image Generation
- **Text-to-Image**: Generate images from text descriptions using Stability AI
- **Multiple Art Styles**: Choose from various artistic styles (Anime, Photographic, Digital Art, etc.)
- **Download & Save**: Save generated images directly to device gallery

### 🖼️ Image Studio
- **Background Removal**: AI-powered background removal using Remove.bg
- **Image Filters**: Apply various color filters and effects
- **Text Overlay**: Add custom text to images
- **Blur Effects**: Apply artistic blur effects
- **Image Cropping**: Precise image cropping tools
- **OCR/Text Recognition**: Extract text from images using Google ML Kit

### 🎨 Theme Support
- **Light/Dark Mode**: Full theme support with easy toggle
- **Modern Design**: Beautiful, responsive UI design

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.8.1
- Dart SDK
- Firebase project (for Gemini AI)
- API keys for external services

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ai_chatbot.git
   cd ai_chatbot
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**
   
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your API keys:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   STABILITY_API_KEY=your_stability_api_key_here
   REMOVEBG_API_KEY=your_removebg_api_key_here
   HF_TOKEN=your_huggingface_token_here
   HUGGINGFACE_API_KEY=your_huggingface_api_key_here
   ```

4. **Configure Firebase**
   
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Firebase AI (Gemini) in your project
   - Download and add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - The `firebase_options.dart` should be configured with your project settings

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 API Keys Setup

| Service | Purpose | Get Key From |
|---------|---------|--------------|
| **Gemini API** | AI Chat & Vision | [Google AI Studio](https://aistudio.google.com/apikey) |
| **Stability AI** | Image Generation | [Stability Platform](https://platform.stability.ai/) |
| **Remove.bg** | Background Removal | [Remove.bg API](https://www.remove.bg/api) |
| **Hugging Face** | Additional AI Models | [Hugging Face](https://huggingface.co/settings/tokens) |

## 📁 Project Structure

```
lib/
├── core/                    # Core utilities
│   ├── env.dart            # Environment variable access
│   ├── error_handling.dart # Error handling utilities
│   └── input_validator.dart# Input validation
├── screens/                 # UI screens
│   ├── home_screen.dart    # Main navigation
│   ├── text_to_text_chat_screen.dart
│   ├── image_to_text_chat_screen.dart
│   ├── text_to_image_screen.dart
│   ├── image_studio_screen.dart
│   └── image_editor_feature/
├── services/               # API services
│   ├── google_service.dart # Gemini AI service
│   ├── stability_ai.dart   # Image generation
│   └── remove_bg_service.dart
├── widgets/                # Reusable widgets
│   ├── shimmer_loading.dart
│   └── ...
├── theme/                  # Theme configuration
│   ├── dark_mode.dart
│   ├── light_mode.dart
│   └── toggle_theme.dart
├── functions/              # Utility functions
├── consts.dart            # App constants
└── main.dart              # App entry point
```

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/input_validator_test.dart

# Run with coverage
flutter test --coverage
```

## 🔒 Security Best Practices

- ⚠️ **Never commit `.env` file** with real API keys
- ✅ Use `.env.example` as a template (safe to commit)
- ✅ API keys are loaded at runtime from environment variables
- ✅ Proper error handling prevents key exposure in logs

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI Framework
- **[Firebase AI](https://firebase.google.com/docs/genai)** - Gemini AI Integration
- **[Stability AI](https://stability.ai/)** - Image Generation
- **[Provider](https://pub.dev/packages/provider)** - State Management
- **[dash_chat_2](https://pub.dev/packages/dash_chat_2)** - Chat UI
- **[flutter_markdown](https://pub.dev/packages/flutter_markdown)** - Markdown Rendering
- **[shimmer](https://pub.dev/packages/shimmer)** - Loading Animations
- **[Google ML Kit](https://pub.dev/packages/google_mlkit_text_recognition)** - Text Recognition

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Google Gemini AI Team
- Stability AI
- Flutter Community
- All open-source contributors

---

Made with ❤️ using Flutter
