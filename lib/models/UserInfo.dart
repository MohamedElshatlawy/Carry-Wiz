import 'dart:convert';

import 'Carry.dart';

UserInfo userInfoFromJson(String str) => UserInfo.fromJson(json.decode(str));

class UserInfo {
  UserInfo({
    required this.userInfoId,
    required this.completedTrips,
    required this.currentRequests,
    required this.completedRequests,
    required this.rating,
    this.nextCarry,
  });

  late int userInfoId;
  late int completedTrips;
  late int currentRequests;
  late int completedRequests;
  late double rating;
  late Carry? nextCarry;

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        userInfoId: json["userInfoId"],
        completedTrips: json["completedTrips"],
        currentRequests: json["currentRequests"],
        completedRequests: json["completedRequests"],
        rating: json["rating"],
        nextCarry: json["nextCarry"] == null ? null : Carry.fromJson(json["nextCarry"]) ,
      );
}
