import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:toast/toast.dart';

import '../components/NetworkSensitive.dart';
import '../components/facebook-login.dart';
import '../components/submit-button.dart';
import '../components/switch-buttons.dart';
import '../injector/injector.dart';
import '../localization/language_constants.dart';
import '../models/UserModel.dart';
import '../screens/forgot-password.dart';
import '../screens/my-home-page.dart';
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../services/messaging.dart';
import '../themes/palette.dart';
import '../utilities/SharedPreferencesManager.dart';
import '../utilities/globals.dart' as globals;
import '../utilities/text-styles.dart';
import '../utilities/validations.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Login screen',
      home: UserLogin(),
    ),
  );
}

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
  late String _email;
  late String _password;

  bool _saving = false;
  bool _autoValidate = false;
  bool googleIsLoggedIn = false;
  FacebookLoginWidget? facebookLoginWidget;

  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  void _turnOnCircularBar() {
    setState(() {
      _saving = true;
    });
  }

  void _turnOffCircularBar() {
    setState(() {
      _saving = false;
    });
  }

  bool _validateInputs() {
    if (_formKey.currentState!.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState!.save();
      return true;
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height),
    );
    // ScreenUtil.init(context, width: MediaQuery.of(context).size.width *
    //     MediaQuery.of(context).devicePixelRatio
    //     , height: MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio);
    // print(MediaQuery.of(context).size.width *
    //     MediaQuery.of(context).devicePixelRatio);
    // print(MediaQuery.of(context).size.height *
    //     MediaQuery.of(context).devicePixelRatio);
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setHeight(55),
                      horizontal: ScreenUtil().setWidth(40)),
                  child: Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            text: 'Carry',
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(35),
                                fontWeight: FontWeight.w400,
                                color: Palette.deepPurple),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'wiz.',
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(35),
                                    fontWeight: FontWeight.w800,
                                    color: Palette.deepPurple),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        SwitchButtons(),
                        SizedBox(
                          height: ScreenUtil().setHeight(25),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            return Validations.validateEmail(val!, context);
                          },
                          onChanged: (String val) {
                            val.toString().trim();
                            _email = val.toLowerCase();
                          },
                          onSaved: (String? val) {
                            _email = val!.toLowerCase();
                          },
                          style: TextStyle(
                              height: ScreenUtil().setHeight(2.5),
                              fontSize: ScreenUtil().setSp(10),
                              fontWeight: FontWeight.w400,
                              color: Palette.deepPurple),
                          decoration: InputDecoration(
                            labelText:
                                getTranslatedValues(context, 'email_address'),
                            hintText:
                                getTranslatedValues(context, 'email_address'),
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.email,
                              color: Palette.lightPurple,
                            ),
                            labelStyle: TextStyles.textFieldStyle,
                            errorStyle: TextStyles.errorStyle,
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Palette.lightPurple,
                                  style: BorderStyle.solid),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.white,
                                  style: BorderStyle.solid),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        TextFormField(
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          validator: (String? val) {
                            if (val!.length == 0 || val.isEmpty)
                              return '*password is required';
                            else
                              return null;
                          },
                          onSaved: (String? val) {
                            _password = val!;
                          },
                          style: TextStyle(
                              height: ScreenUtil().setHeight(2.5),
                              fontSize: ScreenUtil().setSp(10),
                              fontWeight: FontWeight.w400,
                              color: Palette.deepPurple),
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Password",
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Palette.lightPurple,
                            ),
                            labelStyle: TextStyles.textFieldStyle,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.white,
                                  style: BorderStyle.solid),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Palette.lightPurple,
                                  style: BorderStyle.solid),
                            ),
                          ),
                        ),
                        FlatButton(
                          padding: EdgeInsets.only(top: 0, bottom: 0),
                          child: Text('Forgot Password?',
                              style: TextStyle(
                                  color: Palette.lightPurple,
                                  fontSize: ScreenUtil().setSp(15),
                                  fontWeight: FontWeight.w500)),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ForgotPassword()),
                          ),
                          // onPressed: () async {
                          //   String fcmToken =
                          //       await Messaging.firebaseMessaging.getToken();
                          //   // String firebaseToken = _sharedPreferencesManager
                          //   //     .getString('firebase_token');
                          //   print('xxx $fcmToken');
                          // },
                        ),
                        NetworkSensitive(
                          child: Column(
                            children: [
                              SubmitButton(
                                title: getTranslatedValues(
                                    context, 'login_button'),
                                onPressed: () async {
                                  if (_validateInputs()) {
                                    var connectionStatus;
                                    await InternetConnectionChecker()
                                        .connectionStatus
                                        .then((value) {
                                      connectionStatus = value;
                                      print(value);
                                    });
                                    if (connectionStatus ==
                                        InternetConnectionStatus.connected) {
                                      try {
                                        _turnOnCircularBar();
                                        // Token? token = await apiAuthProvider
                                        //     .authenticate();
                                        await apiAuthProvider
                                            .login(
                                                email: _email,
                                                password: _password)
                                            .then((value) async {
                                          _sharedPreferencesManager.putInt(
                                              SharedPreferencesManager
                                                  .keyUserId,
                                              value!.userId);
                                          _sharedPreferencesManager.putString(
                                              SharedPreferencesManager
                                                  .keyUserName,
                                              value.userName);
                                          // _sharedPreferencesManager.putString(
                                          //     SharedPreferencesManager
                                          //         .keyAccessToken,
                                          //     token!.accessToken);
                                          // final storage =
                                          //     new FlutterSecureStorage();
                                          // storage.write(
                                          //     key: SharedPreferencesManager
                                          //         .keyIsLogin,
                                          //     value: 'logged-in');
                                          // await storage.read(
                                          //     key: SharedPreferencesManager
                                          //         .keyIsLogin);
                                          _sharedPreferencesManager.putBool(
                                              SharedPreferencesManager
                                                  .keyIsLogin,
                                              true);
                                          _sendTokenToServer(value.userId);

                                          Toast.show(
                                              getTranslatedValues(
                                                  context, 'login_success'),
                                              context,
                                              duration: Toast.lengthLong,
                                              gravity: Toast.bottom);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => MyHomePage(0)),
                                          );
                                        });
                                      } on DioError catch (error) {
                                        print(error.response.toString());
                                        String errorMessage = HttpNetWork
                                            .checkUserExceptionMessage(
                                                error, context);
                                        _showMessageDialog(errorMessage);
                                      } finally {
                                        _turnOffCircularBar();
                                      }
                                    } else
                                      _showMessageDialog(getTranslatedValues(
                                          context, 'offline_user'));
                                  }
                                },
                                buttonColor: Palette.lightOrange,
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(15),
                              ),
                              Container(
                                  child: _apiSignInButton(
                                      title: getTranslatedValues(
                                          context, 'continue_with_facebook'),
                                      logoURL: 'assets/icons/facebook_logo.png',
                                      function: _initiateFacebookLogin)),
                              SizedBox(
                                height: ScreenUtil().setHeight(15),
                              ),
                              Container(
                                child: _apiSignInButton(
                                    title: getTranslatedValues(
                                        context, 'signin_with_google'),
                                    logoURL: 'assets/icons/google_logo.png',
                                    function: () => signInWithGoogle()
                                            .whenComplete(() async {
                                          if (await globals.googleSignIn
                                              .isSignedIn()) {
                                            try {
                                              _turnOnCircularBar();
                                              await apiAuthProvider
                                                  .authenticate();
                                              UserModel? user = await apiAuthProvider
                                                  .registerApiUser(
                                                      apiUID:
                                                          googleSignInAccount!
                                                              .id,
                                                      name: googleSignInAccount!
                                                          .displayName!,
                                                      email:
                                                          googleSignInAccount!
                                                              .email,
                                                      photoUrl:
                                                          googleSignInAccount!
                                                              .photoUrl!);
                                              _sharedPreferencesManager.putInt(
                                                  SharedPreferencesManager
                                                      .keyUserId,
                                                  user!.userId!);
                                              _sharedPreferencesManager
                                                  .putString(
                                                      SharedPreferencesManager
                                                          .keyUserName,
                                                      user.name!);
                                              _sharedPreferencesManager.putBool(
                                                  SharedPreferencesManager
                                                      .keyIsLogin,
                                                  true);
                                              _sharedPreferencesManager.putBool(
                                                  SharedPreferencesManager
                                                      .keyApiUser,
                                                  true);
                                              _sendTokenToServer(user.userId!);
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          MyHomePage(0)));
                                            } on DioError catch (error) {
                                              String errorMessage = HttpNetWork
                                                  .checkUserExceptionMessage(
                                                      error, context);
                                              _showMessageDialog(errorMessage);
                                            } finally {
                                              _turnOffCircularBar();
                                            }
                                          }
                                        })),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _sendTokenToServer(int userId) async {
    String? fcmToken = await Messaging.firebaseMessaging.getToken();
    if (fcmToken != null)
      apiAuthProvider.updateFirebaseTokenByUserId(userId, fcmToken);
    print('token sent to server');
  }

  void _showMessageDialog(String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            getTranslatedValues(context, 'error'),
          ),
          content: Text(content),
          contentTextStyle: TextStyle(color: Colors.red),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(getTranslatedValues(context, 'error_getting_data')),
              onPressed: () {
                Navigator.of(context).pop();
              },
              textColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  // Google and firebase signin

  User? googleUser;
  GoogleSignInAccount? googleSignInAccount;

  Future<String?> signInWithGoogle() async {
    googleSignInAccount = await globals.googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      googleUser = userCredential.user;

      assert(!googleUser!.isAnonymous);
      assert(await googleUser!.getIdToken() != null);

      final User? currentUser = auth.currentUser;
      assert(googleUser!.uid == currentUser!.uid);
      return 'signInWithGoogle succeeded: $googleUser';
    }
    globals.googleSignIn.disconnect();
  }

  bool isLoggedIn = false;
  var profileData;

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
      print('logged in $isLoggedIn');
    });
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
        final token = result.accessToken!.token;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${token}'));
        final profile = json.decode(graphResponse.body);
        onLoginStatusChanged(true, profileData: profile);
        try {
          _turnOnCircularBar();
          await apiAuthProvider.authenticate();
          UserModel? user = await apiAuthProvider.registerApiUser(
              apiUID: profile['id'],
              name: profile['name'],
              email: profile['email'],
              phoneNumber: '',
              photoUrl: profile['picture']['data']['url']);
          _sharedPreferencesManager.putInt(
              SharedPreferencesManager.keyUserId, user!.userId!);
          _sharedPreferencesManager.putString(
              SharedPreferencesManager.keyUserName, user.name!);
          _sharedPreferencesManager.putBool(
              SharedPreferencesManager.keyIsLogin, true);
          _sharedPreferencesManager.putBool(
              SharedPreferencesManager.keyApiUser, true);
          _sendTokenToServer(user.userId!);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => MyHomePage(0)));
          _turnOnCircularBar();
        } on DioError catch (error) {
          String errorMessage =
              HttpNetWork.checkUserExceptionMessage(error, context);
          _showMessageDialog(errorMessage);
        } finally {
          _turnOffCircularBar();
        }
        break;
      case FacebookLoginStatus.cancel:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.error}');
        onLoginStatusChanged(false);
        break;
    }
  }

  _apiSignInButton(
      {required String title,
      required String logoURL,
      required Function function}) {
    return OutlineButton(
      splashColor: Colors.grey,
      color: Colors.white,
      onPressed: () => function(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      borderSide: BorderSide(color: Colors.blue),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage(logoURL),
              height: ScreenUtil().setHeight(40),
              width: ScreenUtil().setHeight(40),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(16),
                  color: Colors.blueAccent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
