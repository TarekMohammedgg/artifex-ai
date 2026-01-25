import 'dart:developer';
import 'package:artifex_ai/core/error_handling.dart';
import 'package:artifex_ai/core/input_validator.dart';
import 'package:artifex_ai/services/google_service.dart';
import 'package:artifex_ai/widgets/shimmer_loading.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TextToTextScreen extends StatefulWidget {
  const TextToTextScreen({super.key});

  @override
  State<TextToTextScreen> createState() => _TextToTextScreenState();
}

class _TextToTextScreenState extends State<TextToTextScreen> {
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage: "assets/gemini_logo.png",
  );
  List<ChatMessage> messages = [];
  bool isLoading = false;

  @override
  void dispose() {
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
        title: const Text("Gemini Chat"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Show shimmer loading when AI is processing
          if (isLoading) const ChatMessageShimmer(isUserMessage: false),
          Expanded(child: _buildUI()),
        ],
      ),
    );
  }

  Widget _buildUI() {
    final colorScheme = Theme.of(context).colorScheme;

    return DashChat(
      currentUser: currentUser,
      onSend: _sendToGoogle,
      messages: messages,
      messageOptions: MessageOptions(
        messageTextBuilder: (message, _, __) {
          if (message.text.startsWith("Thinking")) {
            return AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  '...',
                  textStyle: TextStyle(color: colorScheme.inversePrimary),
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
              p: TextStyle(color: colorScheme.inversePrimary),
              h1: TextStyle(color: colorScheme.inversePrimary),
              h2: TextStyle(color: colorScheme.inversePrimary),
              h3: TextStyle(color: colorScheme.inversePrimary),
              code: TextStyle(
                color: colorScheme.inversePrimary,
                backgroundColor: colorScheme.tertiary,
              ),
              codeblockDecoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        // User message bubble
        currentUserContainerColor: colorScheme.primary,
        currentUserTextColor: colorScheme.inversePrimary,
        // AI message bubble
        containerColor: colorScheme.secondary,
        textColor: colorScheme.inversePrimary,
        // Avatar
        showCurrentUserAvatar: false,
        showOtherUsersAvatar: true,
        avatarBuilder: (user, _, __) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            backgroundColor: colorScheme.tertiary,
            backgroundImage: user.profileImage != null
                ? AssetImage(user.profileImage!)
                : null,
            child: user.profileImage == null
                ? Icon(Icons.smart_toy, color: colorScheme.inversePrimary)
                : null,
          ),
        ),
      ),
      inputOptions: InputOptions(
        alwaysShowSend: true,
        sendButtonBuilder: (onSend) => IconButton(
          onPressed: onSend,
          icon: Icon(Icons.send_rounded, color: colorScheme.primary),
        ),
        inputTextStyle: TextStyle(color: colorScheme.inversePrimary),
        inputDecoration: InputDecoration(
          hintText: "Type a message...",
          hintStyle: TextStyle(
            color: colorScheme.inversePrimary.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: colorScheme.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
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
      ),
    );
  }

  Future<void> _sendToGoogle(ChatMessage newMessage) async {
    FocusScope.of(context).unfocus();

    // Validate input
    final validationError = InputValidator.validatePrompt(newMessage.text);
    if (validationError != null) {
      _showError(validationError);
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

    log(allMessages);

    setState(() {
      messages = [thinkingMessage, ...messages];
    });

    // Use safe method with error handling
    final result = await GoogleAiService.generateTextSafe(allMessages);

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
          style: TextStyle(color: colorScheme.inversePrimary),
        ),
        backgroundColor: colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: colorScheme.primary,
          onPressed: () {},
        ),
      ),
    );
  }
}
