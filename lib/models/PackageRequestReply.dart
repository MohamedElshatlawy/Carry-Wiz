// To parse required this JSON data, do
//
//     final packageRequestReply = packageRequestReplyFromJson(jsonString);

import 'dart:convert';

import 'package:Carrywiz/models/Carry.dart';
import 'package:Carrywiz/models/RequestCarry.dart';

PackageRequestReply packageRequestReplyFromJson(String str) =>
    PackageRequestReply.fromJson(json.decode(str));

class PackageRequestReply {
  late int packageRequestReplyId;
  late int requestStatus;
  late bool isRead;

  late String packageRequestUniqueKey;
  late DateTime createdAt;
  late RequestCarry requestCarry;
  late Carry carry;

  PackageRequestReply({
    required this.packageRequestReplyId,
    required this.requestStatus,
    required this.packageRequestUniqueKey,
    required this.createdAt,
    required this.requestCarry,
    required this.carry,
    required this.isRead
  });

  factory PackageRequestReply.fromJson(Map<String, dynamic> json) =>
      PackageRequestReply(
        packageRequestReplyId: json["packageRequestReplyId"],
        requestStatus: json["requestStatus"],
        packageRequestUniqueKey: json['packageRequestUniqueKey'],
        createdAt: DateTime.parse(json["createdAt"]),
        requestCarry: RequestCarry.fromJson(
          json["requestCarry"],
        ),
        carry: Carry.fromJson(
          json["carry"],
        ),
          isRead: json['isRead']
      );

}
