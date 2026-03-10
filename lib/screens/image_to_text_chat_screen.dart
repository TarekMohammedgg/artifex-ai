import 'package:artifex_ai/core/error_handling.dart';
import 'package:artifex_ai/widgets/pick_image_with_caption.dart';
import 'package:artifex_ai/services/google_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

class ImageToTextScreen extends StatefulWidget {
  const ImageToTextScreen({super.key});

  @override
  State<ImageToTextScreen> createState() => _ImageToTextScreenState();
}

class _ImageToTextScreenState extends State<ImageToTextScreen> {
  final Gemini gemini = Gemini.instance;
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage: "assets/gemini_logo.png",
  );
  List<ChatMessage> messages = [];
  List<XFile> images = [];
  bool isLoading = false;

  @override
  void dispose() {
    images.clear();
    messages.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.inversePrimary,
        title: const Text("Gemini Vision"),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildUI(),
    );
  }

  IconButton _galleryIconButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () async {
        final result = await Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const PickImageWithCaption(),
          ),
        );

        if (result != null && result['images'] != null) {
          images = List<XFile>.from(result['images']);
          final String caption = result['message'] ?? '';

          // Validate that we have at least a caption or images
          if (caption.isEmpty && images.isEmpty) {
            _showError('Please add a message or select images');
            return;
          }

          final newMessage = ChatMessage(
            user: currentUser,
            createdAt: DateTime.now(),
            text: caption,
            medias: images.map((selectedImage) {
              return ChatMedia(
                url: selectedImage.path,
                fileName: "${DateTime.now()}",
                type: MediaType.image,
              );
            }).toList(),
          );

          await _sendToGoogle(newMessage);
        }
      },
      icon: Icon(Icons.image, color: colorScheme.primary),
    );
  }

  Widget _buildUI() {
    final colorScheme = Theme.of(context).colorScheme;

    return DashChat(
      currentUser: currentUser,
      onSend: _sendToGoogle,
      messages: messages,
      inputOptions: InputOptions(
        alwaysShowSend: true,
        sendButtonBuilder: (onSend) => Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onSend,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.send_rounded, color: colorScheme.primary),
            ),
          ),
        ),
        inputTextStyle: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        inputDecoration: InputDecoration(
          hintText: "Describe the image or ask a question...",
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
        trailing: [_galleryIconButton(context)],
      ),
      messageOptions: MessageOptions(
        messageDecorationBuilder: (message, previousMessage, nextMessage) {
          final isUser = message.user.id == currentUser.id;
          return BoxDecoration(
            color: isUser
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 20),
            ),
          );
        },
        messageTextBuilder: (message, _, __) {
          final isUser = message.user.id == currentUser.id;
          final textColor = isUser
              ? colorScheme.onPrimary
              : colorScheme.onSurface;

          if (message.text.startsWith("Thinking")) {
            return AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  '...',
                  textStyle: TextStyle(color: textColor),
                ),
              ],
              repeatForever: true,
              pause: const Duration(seconds: 1),
              isRepeatingAnimation: true,
            );
          }
          return MarkdownBody(
            data: message.text,
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: textColor),
              h1: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: textColor),
              h2: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: textColor),
              h3: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: textColor),
              code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                backgroundColor: colorScheme.surfaceContainerHigh,
              ),
              codeblockDecoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        // Avatar
        showCurrentUserAvatar: false,
        showOtherUsersAvatar: true,
        avatarBuilder: (user, _, __) => Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: CircleAvatar(
            backgroundColor: colorScheme.surfaceContainerHighest,
            backgroundImage: user.profileImage != null
                ? AssetImage(user.profileImage!)
                : null,
            child: user.profileImage == null
                ? Icon(Icons.smart_toy, color: colorScheme.primary)
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _sendToGoogle(ChatMessage newMessage) async {
    FocusScope.of(context).unfocus();

    // Validate input - allow empty text if images are provided
    if (newMessage.text.isEmpty && (newMessage.medias?.isEmpty ?? true)) {
      _showError('Please enter a message or attach images');
      return;
    }

    setState(() {
      messages = [newMessage, ...messages];
      isLoading = true;
    });

    final thinkingMessage = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: "Thinking",
    );

    final reversedMessages = messages.reversed;
    final allMessages = reversedMessages
        .map((msg) {
          final role = msg.user == geminiUser ? "AI" : "User";
          return "$role: ${msg.text}";
        })
        .join("\n");

    setState(() {
      messages = [thinkingMessage, ...messages];
    });

    // Use safe method with error handling
    final result = await GoogleAiService.generateTextSafe(
      allMessages,
      images.map((file) => file.path).toList(),
    );

    setState(() {
      messages.remove(thinkingMessage);
      isLoading = false;
    });

    if (result.isSuccess && result.data != null) {
      setState(() {
        messages = [
          ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: result.data!,
          ),
          ...messages,
        ];
      });
    } else {
      _showError(result.error ?? ErrorMessages.unknownError);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
        backgroundColor: colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: colorScheme.onErrorContainer,
          onPressed: () {},
        ),
      ),
    );
  }
}
