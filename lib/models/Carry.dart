import 'dart:convert';

import 'package:Carrywiz/models/airport.dart';
import 'package:Carrywiz/models/UserModel.dart';
import 'package:intl/intl.dart';

Carry carryFromJson(String str) => Carry.fromJson(json.decode(str));

String carryToJson(Carry data) => json.encode(data.toJson());

class Carry {
  int? carryId;
  late Airport departureAirport;
  late Airport arrivalAirport;

  int? departureAirportId;

  int? arrivalAirportId;

  late String departureDate;

  late String returnDate;

  int? kilos;

  List<String>? shippingTypes;

  String? deliveryTime;

  String? deliveryLocation;

  bool? completed;

  UserModel? user;

  int get getDepartureAirportId => departureAirportId!;
  Carry(
      {this.carryId,
      this.departureAirportId,
      this.arrivalAirportId,
      required this.departureAirport,
      required this.arrivalAirport,
      required this.departureDate,
      required this.returnDate,
      this.kilos,
      this.shippingTypes,
      this.deliveryTime,
      this.deliveryLocation,
      this.completed,
      this.user});

  set setDepartureAirportId(int departureAirportIdValue) {
    departureAirportId = departureAirportIdValue;
  }

  factory Carry.fromJson(Map<String, dynamic> json) {
    String formattedDepartureDate = DateFormat('dd MMMM yyyy')
        .format(DateTime.parse(json['departureDate']));
    String formattedReturnDate =
        DateFormat('dd MMMM yyyy').format(DateTime.parse(json['returnDate']));
    return Carry(
      carryId: json['carryId'],
      departureAirport: Airport.fromJson(json['departureAirport']),
      arrivalAirport: Airport.fromJson(json['arrivalAirport']),
      departureDate: json['departureDate'],
      returnDate: json['returnDate'],
      kilos: json['kilos'],
      shippingTypes: List<String>.from(json["shippingTypes"].map((x) => x)),
      deliveryTime: json['deliveryTime'],
      deliveryLocation: json['deliveryLocation'],
      completed: json['completed'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() => {
        "departureAirportId": departureAirportId,
        "arrivalAirportId": arrivalAirportId,
        "departureDate": departureDate,
        "returnDate": returnDate,
        "kilos": kilos,
        // "shippingTypes": List<dynamic>.from(shippingTypes.map((x) => x)),
        "deliveryTime": deliveryTime,
        "deliveryLocation": deliveryLocation,
      };
}
