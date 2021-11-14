import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';

bool isLoggedIn = false;

final facebookLogin = FacebookLogin();
final GoogleSignIn googleSignIn = GoogleSignIn();

void signOutGoogle() async {
  await googleSignIn.signOut();
  print("User Signed Out");
}

_logout() async {
  await facebookLogin.logOut();
  print("Logged out");
}
