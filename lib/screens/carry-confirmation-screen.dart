import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../components/carry_card.dart';
import '../screens/my-home-page.dart';
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../services/messaging.dart';
import '../models/Carry.dart';
import '../localization/language_constants.dart';

class CarryConfirmationScreen extends StatefulWidget {
  final Carry carry;

  const CarryConfirmationScreen({required this.carry});

  @override
  _CarryConfirmationScreenState createState() =>
      _CarryConfirmationScreenState();
}

class _CarryConfirmationScreenState extends State<CarryConfirmationScreen> {
  bool _saving = false;
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();

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
    return ModalProgressHUD(
      inAsyncCall: _saving,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                  child: Image.asset(
                'assets/images/finding-request.png',
                fit: BoxFit.fill,
                width: double.infinity,
              )),
              Positioned(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: ScreenUtil().setHeight(150),
                      ),
                      Text(
                        getTranslatedValues(context, 'carry_confirm'),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(50),
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: CarryCard(
                              isExpanded: true,
                              carry: widget.carry,
                              leftButtonTitle: getTranslatedValues(
                                  context, 'confirm_button'),
                              rightButtonTitle:
                                  getTranslatedValues(context, 'cancel_button'),
                              leftButtonCallback: () async {
                                var connectionStatus;
                                InternetConnectionChecker()
                                    .connectionStatus
                                    .then((value) => connectionStatus = value);

                                if (connectionStatus !=
                                    InternetConnectionStatus.connected) {
                                  _turnOnCircularBar();
                                  try {
                                    await apiAuthProvider
                                        .addNewCarry(widget.carry)
                                        .then((value) {
                                      Toast.show(
                                          getTranslatedValues(context,
                                              'space_saved_successfully'),
                                          context,
                                          duration: Toast.lengthLong,
                                          gravity: Toast.bottom);
                                      if (value!.isNotEmpty)
                                        for (String fcmToken in value)
                                          Messaging.sendAndRetrieveMessage(
                                              title: 'Trip Matched',
                                              body:
                                                  'A trip match has been found four your request',
                                              fcmToken: fcmToken);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MyHomePage(2),
                                        ),
                                      );
                                    });
                                  } on DioError catch (error) {
                                    String errorMessage = '';
                                    if (error.response
                                        .toString()
                                        .contains('Cannot_ADD_Two_CARRIES'))
                                      errorMessage = getTranslatedValues(
                                          context, 'two_carries_alert');
                                    else
                                      errorMessage = HttpNetWork
                                          .checkNetworkExceptionMessage(
                                              error, context);
                                    _showMessageDialog(errorMessage);
                                  } finally {
                                    _turnOffCircularBar();
                                  }
                                } else {
                                  _showMessageDialog(getTranslatedValues(
                                      context, 'offline_user'));
                                }
                              },
                              rightButtonCallback: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MyHomePage(2))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
