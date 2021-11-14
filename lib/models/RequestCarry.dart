// To parse required this JSON data, do
//
//     final requestCarry = requestCarryFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

import 'package:Carrywiz/models/UserModel.dart';
import 'package:Carrywiz/models/airport.dart';
import 'package:intl/intl.dart';

RequestCarry requestCarryFromJson(String str) =>
    RequestCarry.fromJson(json.decode(str));

String requestCarryToJson(RequestCarry data) => json.encode(data.toJson());

class RequestCarry {
  UserModel? user;
  int? requestCarryId;

  String? requestDate;
  String? formattedDate;
  String? requestTime;

  String? pickUpLocation;
  String? preferredDelivery;

  int? kilos;

  // bool onDelivery;

  double? packageWidth;
  double? packageHeight;

  String? requestDetailsText;

  String? requestImageURL;

  File? imageFile;

  String? shippingType;

  int? pickupAirportId;
  int? dropOffAirportId;
  Airport? pickupAirport;
  Airport? dropOffAirport;

  RequestCarry({
    this.user,
    this.requestCarryId,
    this.requestDate,
    this.formattedDate,
    this.requestTime,
    this.pickUpLocation,
    this.preferredDelivery,
    this.kilos,
    this.imageFile,
    this.packageWidth,
    this.packageHeight,
    this.requestDetailsText,
    this.requestImageURL,
    this.shippingType,
    this.pickupAirportId,
    this.dropOffAirportId,
    this.pickupAirport,
    this.dropOffAirport,
  });

  factory RequestCarry.fromJson(Map<String, dynamic> json) => (RequestCarry(
      pickupAirport: Airport.fromJson(json['pickupAirport']),
      dropOffAirport: Airport.fromJson(json['dropOffAirport']),
      requestDate: DateFormat('dd MMMM yyyy')
          .format(DateTime.parse(json['requestDate'])),
      formattedDate:
          DateFormat('yyyy-MM-dd').format(DateTime.parse(json['requestDate'])),
      requestTime: json['requestTime'],
      pickUpLocation: json['pickUpLocation'],
      preferredDelivery: json['preferredDelivery'],
      kilos: json['kilos'],
      packageWidth: json['packageWidth'],
      packageHeight: json['packageHeight'],
      requestDetailsText: json['requestDetailsText'],
      requestImageURL: json['requestImageURL'],
      shippingType: json['shippingType'],
      user: UserModel.fromJson(json['user']),
      requestCarryId: json['requestCarryId']));

  Map<String, dynamic> toJson() => {
        "requestDate": requestDate,
        "requestTime": requestTime,
        "pickUpLocation": pickUpLocation,
//        "preferredDelivery": preferredDelivery,
        "kilos": kilos,
        "packageWidth": packageWidth,
        "packageHeight": packageHeight,
        "requestDetailsText": requestDetailsText,
        "requestImageURL": requestImageURL,
        "shippingType": shippingType,
        "pickupAirportId": pickupAirportId,
        "dropOffAirportId": dropOffAirportId,
      };
}
