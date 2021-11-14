import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toast/toast.dart';
import '../screens/carry-trip-screen.dart';
import '../screens/shipping-type-options.dart';
import '../themes/palette.dart';
import '../localization/language_constants.dart';

class ChoosePath extends StatelessWidget {
  final double titleFontSize = 14;
  final double valuesFontSize = 13;

  DateTime? current;
  Future<bool> _onBackButtonPressed(BuildContext context) {
    DateTime now = DateTime.now();
    if (current == null || now.difference(current!) > Duration(seconds: 2)) {
      current = now;
      Toast.show(getTranslatedValues(context, 'back_button_to_exit'), context,
          duration: Toast.lengthLong,
          gravity: Toast.bottom);
      return Future.value(false);
    } else {
      Navigator.pop(context, true);
      SystemNavigator.pop();
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackButtonPressed(context),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Palette.darkPurple,
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil().setHeight(110),
                    ),
                    Text(
                      getTranslatedValues(context, 'start_journey'),
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(350),
                      child: Divider(
                        color: Palette.deepPurple,
                        thickness: ScreenUtil().setHeight(8),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(180),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CarryTrip()),
                          );
                        }),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              Text(
                                getTranslatedValues(context, 'i_can'),
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(100),
                                    fontWeight: FontWeight.w800,
                                    color: Palette.lightViolet),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: getTranslatedValues(context, 'carry'),
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(100),
                                      fontWeight: FontWeight.w400,
                                      color: Palette.lightViolet),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: getTranslatedValues(context, 'wiz'),
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(100),
                                          fontWeight: FontWeight.w800,
                                          color: Palette.lightViolet),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                getTranslatedValues(context, 'have_space'),
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(50),
                                    fontWeight: FontWeight.w800,
                                    color: Palette.lightViolet),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Palette.deepPurple,
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ShippingTypeOptions()),
                        );
                      }),
                      child: Column(
                        children: <Widget>[
                          Text(
                            getTranslatedValues(context, 'i_need'),
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(100),
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                          RichText(
                            text: TextSpan(
                              text: getTranslatedValues(context, 'carry'),
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(100),
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white),
                              children: <TextSpan>[
                                TextSpan(
                                  text: getTranslatedValues(context, 'wiz'),
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(100),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            getTranslatedValues(context, 'need_space'),
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(50),
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
