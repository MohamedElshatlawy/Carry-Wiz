class UserLoginData {
  late String email;
  late String password;

  UserLoginData({required this.email, required this.password});

  factory UserLoginData.fromJson(Map<String, dynamic> json) {
    return UserLoginData(email: json['email'], password: json['password']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    map["password"] = password;

    return map;
  }
}