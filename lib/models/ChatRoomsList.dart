import 'package:Carrywiz/models/ChatRoom.dart';

class ChatRoomsList {
  late  List<ChatRoom> chatRoomsList;

  ChatRoomsList({required this.chatRoomsList});

  factory ChatRoomsList.fromJson(List<dynamic> json) {
    List<ChatRoom> chatRoomsList2 =
        json.map((i) => ChatRoom.fromJson(i)).toList();

    return ChatRoomsList(
      chatRoomsList: chatRoomsList2,
    );
  }
}
