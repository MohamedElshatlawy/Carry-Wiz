import 'dart:convert';

Token tokenFromJson(String str) => Token.fromJson(json.decode(str));

String tokenToJson(Token data) => json.encode(data.toJson());

class Token {
  late String accessToken;
  late String tokenType;
  String? refreshToken;
  late int expiresIn;
  late String scope;
  late String jti;
  late String error;

  Token({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    required this.expiresIn,
    required this.scope,
    required this.jti,
  });

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        refreshToken: json["refresh_token"],
        expiresIn: json["expires_in"],
        scope: json["scope"],
        jti: json["jti"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "refresh_token": refreshToken,
        "expires_in": expiresIn,
        "scope": scope,
        "jti": jti,
      };

  Token.withError(this.error);

  @override
  String toString() {
    return 'Token{accessToken: $accessToken, tokenType: $tokenType, refreshToken: $refreshToken, expiresIn: $expiresIn, scope: $scope, jti: $jti, error: $error}';
  }
}
