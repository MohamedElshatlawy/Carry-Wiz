

import 'dart:convert';

import 'package:Carrywiz/models/ChatRoom.dart';
import 'package:Carrywiz/models/MessageInfo.dart';

ChatMessage chatMessageFromJson(String str) =>
    ChatMessage.fromJson(json.decode(str));

String chatMessageToJson(ChatMessage data) => json.encode(data.toJson());

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.messageBody,
    required this.chatRoomId,
    required this.messageInfo,
  });

  late int id;
  late String messageBody;
  late int chatRoomId;
  late MessageInfo messageInfo;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json["id"],
        messageBody: json["messageBody"],
        chatRoomId: ChatRoom.fromJson(json["chatRoom"]).id,
        messageInfo: MessageInfo.fromJson(json["messageInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "messageBody": messageBody,
        "chatRoomId": chatRoomId,
        "messageInfo": messageInfo.toJson(),
      };
}
