import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../themes/palette.dart';
import '../models/UserInfo.dart';
import '../utilities/text-styles.dart';
import '../localization/language_constants.dart';

class UserInfoWidget extends StatefulWidget {
  final int userId;
  const UserInfoWidget(this.userId);

  @override
  _UserInfoWidgetState createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
  late Future<UserInfo?> _userInfo;
  @override
  void initState() {
    super.initState();
    _userInfo = apiAuthProvider.getUserInfoByUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final defaultSizedBox = SizedBox(height: ScreenUtil().setHeight(40));
    return Column(
      children: <Widget>[
        FutureBuilder<UserInfo?>(
          future: _userInfo,
          builder: (context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.none:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasError) {
                  String errorMessage = snapshot.error.toString();
                  var connectionStatus;
                  InternetConnectionChecker()
                      .connectionStatus
                      .then((value) => connectionStatus = value);

                  if (connectionStatus ==
                      InternetConnectionStatus.disconnected) {
                    errorMessage = 'Oops, you appear to be offline';
                  } else {
                    errorMessage = HttpNetWork.checkNetworkErrorString(
                        errorMessage, context);
                  }
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: Center(
                      child: Text(
                        'Error: $errorMessage',
                        style: TextStyles.errorStyle,
                      ),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${getTranslatedValues(context, 'completed_trips')} ${snapshot.data.completedTrips.toString()}',
                            style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                          ),
                          _verticalDivider(),
                          Text(
                            '${getTranslatedValues(context, 'current_requests')} ${snapshot.data.currentRequests.toString()}',
                            style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                          ),
                        ],
                      ),
                      Center(child: _horizontalDivider()),
                      _titleText(getTranslatedValues(context, 'next_trip')),
                      defaultSizedBox,
                      _doubleTitle(
                        title1:
                            getTranslatedValues(context, 'pick_up_location'),
                        title2:
                            getTranslatedValues(context, 'dropoff_location'),
                      ),
                      defaultSizedBox,
                      snapshot.data.nextCarry != null
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    AutoSizeText(
                                      snapshot
                                          .data.nextCarry.departureAirport.iata,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(50),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    AutoSizeText(
                                      snapshot
                                          .data.nextCarry.arrivalAirport.iata,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(50.0),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Text(
                              getTranslatedValues(context, 'not_available_yet'),
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40)),
                            ),
                      defaultSizedBox,
                      if (snapshot.data.nextCarry != null)
                        _doubleTitle(
                          title1:
                              getTranslatedValues(context, 'departure_date'),
                          title2: getTranslatedValues(context, 'return_date'),
                        ),
                      defaultSizedBox,
                      if (snapshot.data.nextCarry != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            AutoSizeText(
                              snapshot.data.nextCarry.departureDate,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40),
                                  fontWeight: FontWeight.w700),
                            ),
                            AutoSizeText(
                              snapshot.data.nextCarry.returnDate,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40.0),
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      _horizontalDivider()
                    ],
                  );
                }
                return Column(
                  children: <Widget>[],
                );
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ],
    );
  }

  Widget _horizontalDivider() {
    return Container(
      width: ScreenUtil().setWidth(550.0),
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Divider(
        thickness: ScreenUtil().setHeight(4.0),
        color: Palette.lightOrange,
        height: ScreenUtil().setHeight(65),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        width: ScreenUtil().setWidth(60.0),
        height: 30.0,
        child: VerticalDivider(
          thickness: ScreenUtil().setHeight(5.0),
          color: Palette.lightOrange,
          width: ScreenUtil().setWidth(65.0),
        ));
  }

  _titleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(
          fontSize: ScreenUtil().setSp(45), fontWeight: FontWeight.w600),
    );
  }

  Widget _doubleTitle({required String title1, required String title2}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(title1, style: TextStyle(fontSize: ScreenUtil().setSp(45))),
        Text(title2, style: TextStyle(fontSize: ScreenUtil().setSp(45))),
      ],
    );
  }
}
