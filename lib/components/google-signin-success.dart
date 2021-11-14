import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/login_screen.dart';
import '../screens/my-home-page.dart';
import '../themes/palette.dart';
import '../localization/language_constants.dart';

class GoogleSignInSuccess extends StatefulWidget {
  final User user;
  bool isLoggedIn = false;

  @override
  _GoogleSignInSuccessState createState() => _GoogleSignInSuccessState();

  GoogleSignInSuccess(this.user, this.isLoggedIn);
}

class _GoogleSignInSuccessState extends State<GoogleSignInSuccess> {
  var profileData;

  var googleSignIn = GoogleSignIn();

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      isLoggedIn = isLoggedIn;
    });
    print('logged in $isLoggedIn');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(getTranslatedValues(context, 'google_signin')),
            backgroundColor: Palette.deepPurple,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: () =>
                    _logout().then((isLoggedIn) => isLoggedIn ? _logout() : {}),
              ),
            ],
          ),
          body: Container(
            child: Center(
              child: _displayUserData(),
            ),
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

  _displayUserData() {
    var user = widget.user;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 150.0,
          width: 150.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                user.photoURL!,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          getTranslatedValues(context, 'welcome') +
              "${user.displayName}\n${user.email}",
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: Text(getTranslatedValues(context, 'continue_to_app')),
          onPressed: () => widget.isLoggedIn
              ? Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (_) => MyHomePage(0),
                  ),
                )
              : null,
          color: Colors.red,
          textColor: Colors.white,
        ),
      ],
    );
  }

  _logout() async {
    await googleSignIn.signOut();
    onLoginStatusChanged(false);
    print(widget.isLoggedIn);
    Navigator.push(context, new MaterialPageRoute(builder: (_) => UserLogin()));
    print("User Sign Out");
  }
}
