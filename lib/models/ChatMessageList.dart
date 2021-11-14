import 'package:Carrywiz/models/ChatMessage.dart';

class ChatMessagesList {
  late List<ChatMessage> chatMessages;

  ChatMessagesList({required this.chatMessages});

  factory ChatMessagesList.fromJson(List<dynamic> json) {
    List<ChatMessage> chatMessages2 =
        json.map((i) => ChatMessage.fromJson(i)).toList();

    return ChatMessagesList(
      chatMessages: chatMessages2,
    );
  }
}
