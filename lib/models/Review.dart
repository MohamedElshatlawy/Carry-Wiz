// To parse required this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

import 'package:Carrywiz/models/MessageInfo.dart';

List<Review> reviewFromJson(String str) =>
    List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
  Review({
    required this.id,
    required this.reviewMessage,
    required this.messageInfo,
    required this.rating,
  });

  late int id;
  late String reviewMessage;
  late MessageInfo messageInfo;
  late double rating;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        reviewMessage: json["reviewMessage"],
        messageInfo: MessageInfo.fromJson(json["messageInfo"]),
        rating: json["rating"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reviewMessage": reviewMessage,
        "messageInfo": messageInfo.toJson(),
        "rating": rating,
      };
}
