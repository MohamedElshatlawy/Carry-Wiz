import 'dart:convert';

import 'package:Carrywiz/models/MessageInfo.dart';

List<ChatRoom> chatRoomFromJson(String str) =>
    List<ChatRoom>.from(json.decode(str).map((x) => ChatRoom.fromJson(x)));

String chatRoomToJson(List<ChatRoom> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatRoom {
  late int id;
  late MessageInfo chatInfo;

  ChatRoom({
   required this.id,
   required this.chatInfo,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
        id: json["id"],
        chatInfo: MessageInfo.fromJson(json["chatInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "chatInfo": chatInfo.toJson(),
      };
}
