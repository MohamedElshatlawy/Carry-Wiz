import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../localization/language_constants.dart';
import '../screens/signup-screen.dart';
import '../utilities/text-styles.dart';

class Gender extends StatefulWidget {
  static late String _gender;

  const Gender({this.darkText});

  static String get gender => _gender;
  final bool? darkText;

  static set gender(String value) {
    _gender = value;
  }

  @override
  _Gender createState() => new _Gender();
}

class _Gender extends State<Gender> {
  UserRegister? userRegister;
  bool hasError = false;
  bool _pressedMale = false;
  bool _pressedFemale = false;

  @override
  Widget build(BuildContext context) {
//    ScreenUtil.init(context, allowFontScaling: true);
    return FormField(
      validator: (value) {
        if (value == null)
          return getTranslatedValues(context, 'required_field');
        else
          return null;
      },
      builder: (FormFieldState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  getTranslatedValues(context, 'gender'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: widget.darkText! ? null : Colors.white,
                      fontSize: ScreenUtil().setSp(20)),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.male,
                    color: _pressedMale ? Colors.amber : Colors.grey,
                    size: ScreenUtil().setSp(30),
                  ),
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // shape: CircleBorder(),
                  // elevation: 2.0,
                  // fillColor: _pressedMale ? Colors.white : Colors.grey,
                  // color:  _pressedMale ? Colors.white : Colors.grey,
                  highlightColor: Colors.green,
                  disabledColor: Colors.purple,
                  hoverColor: Colors.green,
                  focusColor: Colors.blue,
                  splashColor: Colors.black,
                  color: Colors.blueGrey,
                  onPressed: () {
                    setState(() {
                      _pressedMale = true;
                      _pressedFemale = false;
                      Gender._gender = "Male";
                      state.didChange(state);
                    });
                  },
                ),
                Text(
                  getTranslatedValues(context, 'male'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: widget.darkText! ? null : Colors.white,
                      fontSize: ScreenUtil().setSp(20)),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.female,
                    color: _pressedFemale ? Colors.amber : Colors.grey,
                    size: ScreenUtil().setSp(30),
                  ),
                  color: _pressedFemale ? Colors.white : Colors.grey,
                  onPressed: () {
                    setState(() {
                      _pressedMale = false;
                      _pressedFemale = true;
                      Gender._gender = "Female";
                      state.didChange(state);
                    });
                  },
                ),
                Text(
                  getTranslatedValues(context, 'female'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: widget.darkText! ? null : Colors.white,
                      fontSize: ScreenUtil().setSp(20)),
                ),
              ],
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: TextStyles.errorStyle,
                textAlign: TextAlign.left,
              )
          ],
        );
      },
    );
  }
}
