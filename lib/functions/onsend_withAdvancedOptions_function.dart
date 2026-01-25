
  // void _onSendMessage(ChatMessage newMessage) async {
  //   // limit is 60 request in minute
  //   setState(() {
  //     messages = [newMessage, ...messages];
  //   });
  //   try {
  //     final String request = newMessage.text;
  //     final List<Part> parts = [Part.text(request)];
  //     if (newMessage.medias?.isNotEmpty ?? false) {
  //       parts.add(
  //         Part.uint8List(File(newMessage.medias!.first.url).readAsBytesSync()),
  //       );
  //     }
  //     gemini.promptStream(parts: parts ).listen((response) {
  //       ChatMessage? lastMessage = messages.firstOrNull;
  //       if (lastMessage != null && lastMessage.user == geminiUser) {
  //         lastMessage = messages.removeAt(0);

  //         List<String?> res = [response?.output, ""];
  //         String text = res.join(" ");
  //         lastMessage.text += text;
  //         setState(() {
  //           messages = [lastMessage!, ...messages];
  //         });
  //       } else {
  //         List<String?> res = [response?.output, ""];
  //         String text = res.join(" ");

  //         ChatMessage message = ChatMessage(
  //           user: geminiUser,
  //           createdAt: DateTime.now(),
  //           text: text,
  //         );
  //         setState(() {
  //           messages = [message, ...messages];
  //         });
  //       }
  //     });
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }