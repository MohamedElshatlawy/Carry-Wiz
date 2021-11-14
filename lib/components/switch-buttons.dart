import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/login_screen.dart';
import '../themes/palette.dart';
import '../screens/signup-screen.dart';
import '../localization/language_constants.dart';

class SwitchButtons extends StatefulWidget {
  @override
  _SwitchButtonsState createState() => new _SwitchButtonsState();
}

class _SwitchButtonsState extends State<SwitchButtons> {
  static bool _signUpActive = false;
  static bool _signInActive = true;

  static void _changeToSignUp() {
    _signUpActive = true;
    _signInActive = false;
  }

  static void _changeToSignIn() {
    _signUpActive = false;
    _signInActive = true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  _buttonTheme(
                      _onPressedSignIn,
                      _signInActive,
                      getTranslatedValues(context, 'sign_in'),
                      Colors.white,
                      Palette.deepPurple,
                      Palette.lightOrange),
                  SizedBox(
                    width: ScreenUtil().setWidth(50),
                  ),
                  _buttonTheme(
                      _onPressedSignUp,
                      _signUpActive,
                      getTranslatedValues(context, 'sign_up'),
                      Colors.white,
                      Palette.deepPurple,
                      Palette.lightOrange),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _onPressedSignIn() {
    setState(() {
      _changeToSignIn();
      new BorderSide(
        style: BorderStyle.solid,
        color: Colors.grey,
      );
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserLogin(),
      ),
    );
  }

  _onPressedSignUp() {
    setState(() {
      print('ok');
      _changeToSignUp();
      BorderSide(
        style: BorderStyle.solid,
        color: Colors.grey,
      );
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserRegister(),
      ),
    );
  }

  _buttonTheme(VoidCallback _onPressed, bool _activeButton, String title,
      Color textColor1, Color textColor2, Color color) {
    return ButtonTheme(
      minWidth: ScreenUtil().setWidth(300),
      height: ScreenUtil().setHeight(140),
      child: RaisedButton(
        onPressed: _onPressed,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: _activeButton ? textColor1 : textColor2,
        color: _activeButton ? color : textColor1,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10),
        ),
        child: new Text(
          title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(50),
          ),
        ),
      ),
    );
  }
}
