import 'package:Carrywiz/components/NetworkSensitive.dart';
import 'package:Carrywiz/components/submit-button.dart';
import 'package:Carrywiz/services/ApiAuthProvider.dart';
import 'package:Carrywiz/services/HttpNetwork.dart';
import 'package:Carrywiz/themes/palette.dart';
import 'package:Carrywiz/utilities/text-styles.dart';
import 'package:Carrywiz/utilities/validations.dart';
import '../localization/language_constants.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ChangeProperty extends StatefulWidget {
  final String changedProperty;

  const ChangeProperty({required this.changedProperty});

  @override
  _ChangePropertyState createState() => _ChangePropertyState();
}

class _ChangePropertyState extends State<ChangeProperty> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _currentPassword;
  late String _newProperty;

  bool _autoValidate = false;

  bool _saving = false;

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

  @override
  Widget build(BuildContext context) {
    final defaultSizedBox = SizedBox(
      height: ScreenUtil().setHeight(35),
    );
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _saving,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Container(
                height: ScreenUtil().setHeight(1853),
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setHeight(20),
                    horizontal: ScreenUtil().setWidth(50)),
                margin: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(20),
                  horizontal: ScreenUtil().setWidth(100),
                ),
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: ScreenUtil().setHeight(550.0),
                      ),
                      Text(
                        getTranslatedValues(context, 'enter_current_password'),
                        style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                      ),
                      defaultSizedBox,
                      TextFormField(
                        autofocus: false,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        style: TextStyle(height: 1),
                        validator: (String? val) {
                          if (val!.length == 0 || val.isEmpty)
                            return getTranslatedValues(
                                context, 'required_field');
                          else
                            return null;
                        },
                        onSaved: (String? val) {
                          _currentPassword = val!;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyles.errorStyle,
                          labelText: getTranslatedValues(
                              context, 'current_password_hint'),
                          hintText: getTranslatedValues(
                              context, 'current_password_hint'),
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Palette.lightPurple,
                          ),
                          labelStyle: TextStyle(
                              color: Palette.lightPurple,
                              fontSize: ScreenUtil().setSp(50),
                              fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                                width: 1,
                                color: Colors.white,
                                style: BorderStyle.solid),
                          ),
                        ),
                      ),
                      defaultSizedBox,
                      Text(
                        widget.changedProperty == 'Password'
                            ? getTranslatedValues(context, 'enter_new_password')
                            : getTranslatedValues(context, 'enter_new_email'),
                        style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                      ),
                      defaultSizedBox,
                      TextFormField(
                        autofocus: false,
                        obscureText: (widget.changedProperty == 'Password')
                            ? true
                            : false,
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (widget.changedProperty == 'Password')
                            return Validations.validatePassword(val!, context);
                          else
                            return Validations.validateEmail(val!, context);
                        },
                        onSaved: (String? val) {
                          _newProperty = val!;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyles.errorStyle,
                          labelText: widget.changedProperty == 'Password'
                              ? getTranslatedValues(
                                  context, 'new_password_hint')
                              : getTranslatedValues(context, 'new_email_hint'),
                          hintText: widget.changedProperty == 'Password'
                              ? getTranslatedValues(
                                  context, 'new_password_hint')
                              : getTranslatedValues(context, 'new_email_hint'),
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.keyboard,
                            color: Palette.lightPurple,
                          ),
                          labelStyle: TextStyle(
                              color: Palette.lightPurple,
                              fontSize: ScreenUtil().setSp(50),
                              fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                                width: 1,
                                color: Colors.green,
                                style: BorderStyle.solid),
                          ),
                        ),
                      ),
                      defaultSizedBox,
                      NetworkSensitive(
                        child: SubmitButton(
                          title: widget.changedProperty == 'Password'
                              ? getTranslatedValues(context, 'change_password')
                              : getTranslatedValues(context, 'change_email'),
                          onPressed: () async {
                            if (_validateInputs()) {
                              var connectionStatus;
                              InternetConnectionChecker()
                                  .connectionStatus
                                  .then((value) => connectionStatus = value);

                              if (connectionStatus !=
                                  InternetConnectionStatus.connected) {
                                _turnOnCircularBar();
                                ApiAuthProvider apiAuthProvider =
                                    ApiAuthProvider();
                                try {
                                  if (widget.changedProperty
                                      .contains('Password')) {
                                    await apiAuthProvider.changePassword(
                                        _currentPassword, _newProperty);
                                  } else if (widget.changedProperty
                                      .contains('Email')) {
                                    await apiAuthProvider.changeEmail(
                                        _currentPassword, _newProperty);
                                  }
                                  Toast.show(
                                      widget.changedProperty == 'Password'
                                          ? getTranslatedValues(
                                              context, 'password_changed')
                                          : getTranslatedValues(
                                              context, 'email_changed'),
                                      context,
                                      duration: Toast.lengthLong,
                                      gravity: Toast.bottom);
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      '/settings_screen', (_) => false);
                                } on DioError catch (error) {
                                  String errorMessage =
                                      HttpNetWork.checkUserExceptionMessage(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(getTranslatedValues(context, 'error')),
          content: Text(content),
          contentTextStyle: TextStyle(color: Colors.red),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(getTranslatedValues(context, 'try_again')),
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
}
