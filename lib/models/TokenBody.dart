import 'dart:convert';

TokenBody tokenBodyFromJson(String str) => TokenBody.fromJson(json.decode(str));

String tokenBodyToJson(TokenBody data) => json.encode(data.toJson());

class TokenBody {
  late  String grantType;

  TokenBody({
    required this.grantType,
  });

  factory TokenBody.fromJson(Map<String, dynamic> json) => TokenBody(
        grantType: json["grant_type"],
      );

  Map<String, dynamic> toJson() => {
        "grant_type": grantType,
      };
}
