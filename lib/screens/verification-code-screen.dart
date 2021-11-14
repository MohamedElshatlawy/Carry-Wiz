import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../components/NetworkSensitive.dart';
import '../components/submit-button.dart';
import '../models/UserModel.dart';
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../themes/palette.dart';
import '../utilities/text-styles.dart';
import '../localization/language_constants.dart';

class VerificationCodeScreen extends StatefulWidget {
  final UserModel userModel;
  final String activationCode;
  final String? email;
  final bool registration;

  const VerificationCodeScreen(
      {required this.userModel,
      required this.activationCode,
      this.email,
      required this.registration});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  bool _saving = false;

  var _activationCodeController = TextEditingController();

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
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Container(
                height: ScreenUtil().setHeight(1750),
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
                        getTranslatedValues(context, 'enter_verification_code'),
                        style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                      ),
                      defaultSizedBox,
                      TextFormField(
                        controller: _activationCodeController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(height: 1),
                        validator: (val) {
                          if (val!.length == 0 || val.isEmpty)
                            return getTranslatedValues(
                                context, 'required_field');
                        },
                        maxLength: 6,
                        decoration: InputDecoration(
                          errorStyle: TextStyles.errorStyle,
                          labelText: getTranslatedValues(
                              context, 'verification_code_hint'),
                          hintText: getTranslatedValues(
                              context, 'verification_code_hint'),
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.verified_user,
                          ),
                          labelStyle: TextStyle(
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
                      NetworkSensitive(
                        child: SubmitButton(
                          title:
                              getTranslatedValues(context, 'register_button'),
                          buttonColor: Palette.lightOrange,
                          onPressed: () async {
                            if (_validateInputs()) {
                              var connectionStatus;
                              InternetConnectionChecker()
                                  .connectionStatus
                                  .then((value) => connectionStatus = value);
                              if (connectionStatus ==
                                  InternetConnectionStatus.connected) {
                                _turnOnCircularBar();
                                try {
                                  ApiAuthProvider apiAuthProvider =
                                      ApiAuthProvider();
                                  await apiAuthProvider
                                      .registerUser(widget.userModel)
                                      .then((value) {
                                    Toast.show(
                                        getTranslatedValues(context,
                                            'account_registered_successfully'),
                                        context,
                                        duration: Toast.lengthLong,
                                        gravity: Toast.bottom);
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/login_screen', (_) => false);
                                  });
                                } on DioError catch (error) {
                                  String errorMessage =
                                      HttpNetWork.checkNetworkExceptionMessage(
                                          error, context);
                                  _showMessageDialog(errorMessage);
                                } finally {
                                  _turnOffCircularBar();
                                }
                              } else {
                                _showMessageDialog(getTranslatedValues(
                                    context, 'offline_user'));
                              }
                            }
                          },
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
