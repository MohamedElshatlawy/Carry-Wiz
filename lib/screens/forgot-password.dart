import 'package:Carrywiz/components/NetworkSensitive.dart';
import 'package:Carrywiz/components/submit-button.dart';
import 'package:Carrywiz/services/ApiAuthProvider.dart';
import 'package:Carrywiz/services/HttpNetwork.dart';
import 'package:Carrywiz/themes/palette.dart';
import 'package:Carrywiz/utilities/text-styles.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../localization/language_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ForgotPassword extends StatefulWidget {
  final String? changedProperty;

  const ForgotPassword({this.changedProperty});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _email;

  bool _autoValidate = false;

  bool _saving = false;

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
                        getTranslatedValues(context, 'enter_your_email'),
                        style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                      ),
                      defaultSizedBox,
                      TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        validator: (String? val) {
                          if (val!.length == 0 || val.isEmpty)
                            return getTranslatedValues(
                                context, 'current_password_is_required');
                          else
                            return null;
                        },
                        onSaved: (String? val) {
                          _email = val!;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyles.errorStyle,
                          labelText:
                              getTranslatedValues(context, 'email_address'),
                          hintText:
                              getTranslatedValues(context, 'email_address'),
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
                          title: getTranslatedValues(
                              context, 'reset_password_button'),
                          onPressed: () async {
                            if (_validateInputs()) {
                              var connectionStatus;
                              InternetConnectionChecker()
                                  .connectionStatus
                                  .then((value) => connectionStatus = value);
                              if (connectionStatus ==
                                  InternetConnectionStatus.connected) {
                                try {
                                  _turnOnCircularBar();
                                  ApiAuthProvider apiAuthProvider =
                                      ApiAuthProvider();
                                  await apiAuthProvider
                                      .forgotPassword(_email)
                                      .then((value) {
                                    Toast.show(
                                        getTranslatedValues(
                                            context, 'password_sent'),
                                        context,
                                        duration: Toast.lengthLong,
                                        gravity: Toast.bottom);

                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/login_screen', (_) => false);
                                  });
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
}
