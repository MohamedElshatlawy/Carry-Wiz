import 'dart:async';

import 'package:Carrywiz/utilities/text-styles.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../components/carry_card.dart';
import '../components/request-card.dart';
import '../components/submit-button.dart';
import '../screens/profile-info-screen.dart';
import '../services/HttpNetwork.dart';
import '../services/messaging.dart';
import '../models/Carry.dart';
import '../models/CarryResponseList.dart';
import '../models/RequestCarry.dart';
import '../services/ApiAuthProvider.dart';
import '../localization/language_constants.dart';
import '../themes/palette.dart';

class FindingMatchedCarry extends StatefulWidget {
  final RequestCarry requestCarry;

  FindingMatchedCarry({required this.requestCarry});

  @override
  _FindingMatchedCarryState createState() => _FindingMatchedCarryState();
}

class _FindingMatchedCarryState extends State<FindingMatchedCarry> {
  @override
  void initState() {
    super.initState();
    carryResponseList = apiAuthProvider.getAllMatchedCarries(
      pickUpAirportId: requestCarry.pickupAirport!.id!,
      dropOffAirportId: requestCarry.dropOffAirport!.id!,
      requestDate: requestCarry.formattedDate!,
      kilos: requestCarry.kilos!,
      userId: requestCarry.user!.userId!,
    );
  }

  ApiAuthProvider apiAuthProvider = ApiAuthProvider();

  late RequestCarry requestCarry;

  List<RequestCarry> requestCarryResponseList = [];

  List<Carry>? carries = [];
  late Future<CarryResponseList?> carryResponseList;

  _showSnackBar(context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
        getTranslatedValues(context, 'request_sent_to_carrier'),
      ),
      action: SnackBarAction(
        label: '',
        onPressed: () {},
      ),
    ));
  }

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _saving,
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
                        height: ScreenUtil().setHeight(600),
                      ),
                      FutureBuilder<CarryResponseList?>(
                          future: carryResponseList,
                          builder: (context,
                              AsyncSnapshot<CarryResponseList?> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.active:
                              case ConnectionState.none:
                                return SizedBox(
                                  height: ScreenUtil().screenHeight / 1.3,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  String errorMessage =
                                      snapshot.error.toString();
                                  var connectionStatus;
                                  InternetConnectionChecker()
                                      .connectionStatus
                                      .then(
                                          (value) => connectionStatus = value);

                                  if (connectionStatus !=
                                      InternetConnectionStatus.connected) {
                                    errorMessage =
                                        'Oops, you appear to be offline';
                                    errorMessage =
                                        HttpNetWork.checkNetworkErrorString(
                                            errorMessage, context);
                                  }
                                  return SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    child: Center(
                                      child: Text(
                                        'Error: $errorMessage',
                                        style: TextStyles.errorStyle,
                                      ),
                                    ),
                                  );
                                }
                                if (snapshot.hasData) {
                                  if (snapshot
                                      .data!.carryResponsesList.isEmpty) {
                                    return Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: ScreenUtil().setHeight(150),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: getTranslatedValues(
                                                context, 'unfortunately'),
                                            style: TextStyle(
                                              fontSize: ScreenUtil().setSp(70),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: getTranslatedValues(
                                                    context,
                                                    'couldnot_find_wizard'),
                                                style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(50),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              child: Card(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: ScreenUtil()
                                                        .setWidth(60),
                                                    vertical: ScreenUtil()
                                                        .setHeight(25)),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0))),
                                                child: RequestCarryInfo(
                                                  requestCarry: requestCarry,
                                                ),
                                              ),
                                              width:
                                                  ScreenUtil().setWidth(1000),
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        ),
                                      ],
                                    );
                                  } else
                                    carries = snapshot.data!.carryResponsesList;
                                  return Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: ListView.builder(
                                          primary: false,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: carries!.length,
                                          itemBuilder: (context, int index) {
                                            int carrierId =
                                                carries![index].user!.userId!;
                                            return CarryCard(
                                              isExpanded: true,
                                              carry: carries![index],
                                              leftButtonTitle:
                                                  getTranslatedValues(context,
                                                      'send_request_button'),
                                              rightButtonTitle:
                                                  getTranslatedValues(context,
                                                      'check_profile_button'),
                                              leftButtonCallback: () async {
                                                //send request to carrier
                                                var connectionStatus;
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);
                                                if (connectionStatus ==
                                                    InternetConnectionStatus
                                                        .disconnected) {
                                                  try {
                                                    _turnOnCircularBar();
                                                    await apiAuthProvider
                                                        .sendPackageRequest(
                                                            requestCarry
                                                                .requestCarryId!,
                                                            carries![index]
                                                                .carryId!)
                                                        .then((value) {
                                                      setState(() {
                                                        _showSnackBar(context);
                                                        Messaging.sendAndRetrieveMessage(
                                                            title:
                                                                'Request Received',
                                                            body:
                                                                'A requester sent you a package request',
                                                            fcmToken: carries![
                                                                    index]
                                                                .user!
                                                                .firebaseToken!);
                                                        Navigator
                                                            .pushNamedAndRemoveUntil(
                                                                context,
                                                                '/home_screen',
                                                                (_) => false);
                                                      });
                                                    });
                                                  } on DioError catch (error) {
                                                    String errorMessage = '';
                                                    if (error.response
                                                        .toString()
                                                        .contains(
                                                            'KILOS_EXCEEDS')) {
                                                      errorMessage =
                                                          getTranslatedValues(
                                                              context,
                                                              'kilos_exceed');
                                                    } else {
                                                      errorMessage = HttpNetWork
                                                          .checkNetworkExceptionMessage(
                                                              error, context);
                                                    }
                                                    _showMessageDialog(
                                                        errorMessage);
                                                  } finally {
                                                    _turnOffCircularBar();
                                                  }
                                                } else
                                                  _showMessageDialog(
                                                      getTranslatedValues(
                                                          context,
                                                          'offline_user'));
                                              },
                                              rightButtonCallback: () =>
                                                  Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ProfileInfo(
                                                          userId: carrierId,
                                                        )),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            }
                            return Center(
                              child: Text(
                                getTranslatedValues(
                                    context, 'error_getting_data'),
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: ScreenUtil().setSp(70)),
                              ),
                            );
                          }),
                      SizedBox(
                        height: ScreenUtil().setHeight(50),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(880),
                        child: SubmitButton(
                          buttonColor: Palette.lightGreen,
                          title: getTranslatedValues(
                              context, 'back_to_home_button'),
                          onPressed: (() {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home_screen', (_) => false);
                          }),
                        ),
                      )
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
