import 'dart:convert';

UserModel userFromJson(String str) => UserModel.fromJson(json.decode(str));

String userToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  int? userId;
  String? name;
  String? dateOfBirth;
  String? gender;
  String? phoneNumber;
  String? countryDialCode;
  String? email;
  String? password;
  String? country;
  String? profileImageUrl;
  DateTime? dateOfJoin;
  String? apiUID;

  String? firebaseToken;

  UserModel(
      {this.profileImageUrl,
      this.userId,
      this.name,
      this.dateOfBirth,
      this.gender,
      this.phoneNumber,
      this.password,
      this.countryDialCode,
      this.email,
      this.country,
      this.dateOfJoin,
      this.apiUID,
      this.firebaseToken});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json["userId"],
        name: json["name"],
        dateOfBirth: json["dateOfBirth"] ?? '',
        gender: json["gender"] ?? '',
        phoneNumber: json["phoneNumber"] ?? '',
        countryDialCode: json['countryDialCode'] ?? '',
        email: json["email"],
        country: json["country"] ?? '',
        profileImageUrl: json["profileImageUrl"] ?? '',
        dateOfJoin: DateTime.parse(json["dateOfJoin"]),
        apiUID: json['apiUID'] ?? '',
        firebaseToken: json['firebaseToken'],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "password": password,
        "dateOfBirth": dateOfBirth,
        "gender": gender,
        "phoneNumber": phoneNumber,
        'countryDialCode': countryDialCode,
        "email": email,
        "country": country,
        "profileImageUrl": profileImageUrl,
      };
}
