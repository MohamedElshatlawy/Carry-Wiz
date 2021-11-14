// To parse this JSON data, do
//
//     final packageRequest = packageRequestFromJson(jsonString);

import 'dart:convert';

import 'package:Carrywiz/models/Carry.dart';
import 'package:Carrywiz/models/RequestCarry.dart';

PackageRequest packageRequestFromJson(String str) =>
    PackageRequest.fromJson(json.decode(str));


class PackageRequest {
  late int packageRequestId;
  late int requestStatus;
  late bool isRead;
  late String packageRequestUniqueKey;
  late  DateTime createdAt;
  late  RequestCarry requestCarryResponse;
  late Carry carry;

  PackageRequest(
      {
      required this.packageRequestId,
      required this.requestStatus,
      required this.packageRequestUniqueKey,
      required this.createdAt,
      required this.requestCarryResponse,
      required this.carry,
      required this.isRead});

  factory PackageRequest.fromJson(Map<String, dynamic> json) => PackageRequest(
      packageRequestId: json["packageRequestId"],
      requestStatus: json["requestStatus"],
      packageRequestUniqueKey: json['packageRequestUniqueKey'],
      createdAt: DateTime.parse(json["createdAt"]),
      requestCarryResponse: RequestCarry.fromJson(json["requestCarry"]),
      carry: Carry.fromJson(json["carry"]),
      isRead: json['isRead']);


}
