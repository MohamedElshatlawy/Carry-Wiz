import 'package:Carrywiz/models/UserModel.dart';

class MessageInfo {
  late int id;
  late UserModel sender;
  late UserModel recipient;
  late DateTime createdAt;
  late bool deletedBySender;
  late bool deletedByRecipient;
  late bool isRead;

  MessageInfo(
      {required this.id,
      required this.sender,
      required this.recipient,
      required this.createdAt,
      required this.deletedBySender,
      required this.deletedByRecipient,
      required this.isRead});

  factory MessageInfo.fromJson(Map<String, dynamic> json) => MessageInfo(
      id: json["id"],
      sender: UserModel.fromJson(json["sender"]),
      recipient: UserModel.fromJson(json["recipient"]),
      createdAt: DateTime.parse(json["createdAt"]),
      deletedBySender: json["deletedBySender"],
      deletedByRecipient: json["deletedByRecipient"],
      isRead: json['isRead']);

  Map<String, dynamic> toJson() => {
        "id": id,
        // "sender": User(),
        // "recipient": User.toJson(),
        "createdAt":
            "${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}",
        "deletedBySender": deletedBySender,
        "deletedByRecipient": deletedByRecipient,
      };
}
