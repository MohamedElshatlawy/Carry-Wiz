import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:http/http.dart' as http;
import '../screens/my-home-page.dart';
import '../screens/login_screen.dart';
import '../localization/language_constants.dart';

class FacebookLoginWidget extends StatefulWidget {
  @override
  _FacebookLoginWidgetState createState() => _FacebookLoginWidgetState();
}

class _FacebookLoginWidgetState extends State<FacebookLoginWidget> {
  bool isLoggedIn = false;
  var profileData;

  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
      print('logged in $isLoggedIn');
    });
  }

  @override
  void initState() {
    super.initState();
    _initiateFacebookLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(getTranslatedValues(context, 'facebook_login')),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () => facebookLogin.isLoggedIn
                  .then((isLoggedIn) => isLoggedIn ? _logout() : {}),
            ),
          ],
        ),
        body: Container(
          child: Center(
            child: isLoggedIn ? _displayUserData(profileData) : null,
          ),
        ),
      ),
      theme: ThemeData(
        fontFamily: 'Raleway',
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.grey[600],
            ),
        // This colors the [InputOutlineBorder] when it is selected
        primaryColor: Colors.blue[500],
        textSelectionHandleColor: Colors.blue[500],
      ),
    );
  }

  void _initiateFacebookLogin() async {
    // Create an instance of FacebookLogin
    final fb = FacebookLogin();

    // Log in
    final result = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (result.status) {
      case FacebookLoginStatus.success:
        final FacebookAccessToken? accessToken = result.accessToken;
        final token = result.accessToken!.token;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=$token'));
        final profile = json.decode(graphResponse.body);
        print('Login successfully.');
        onLoginStatusChanged(true, profileData: profile);
        break;
      case FacebookLoginStatus.cancel:
        onLoginStatusChanged(false);
        print('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.error}');
        onLoginStatusChanged(false);
        break;
    }
  }

  _displayUserData(profileData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 200.0,
          width: 200.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                profileData['picture'],
              ),
            ),
          ),
        ),
        SizedBox(height: 28.0),
        Text(
          getTranslatedValues(context, 'welcome') +
              "${profileData['name']}\n${profileData['email']}",
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: Text(getTranslatedValues(context, 'continue_to_app')),
          onPressed: () => isLoggedIn
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyHomePage(0),
                  ),
                )
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserLogin(),
                  ),
                ),
          color: Colors.blue,
          textColor: Colors.white,
        ),
      ],
    );
  }

  _logout() async {
    await facebookLogin.logOut();
    onLoginStatusChanged(false);
    Navigator.push(context, MaterialPageRoute(builder: (_) => UserLogin()));
  }
}
