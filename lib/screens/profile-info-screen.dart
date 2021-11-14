import '../components/default-app-bar-widget.dart';
import 'reviews-list-screen.dart';
import '../components/user-data.dart';
import '../components/user-info-widget.dart';
import '../themes/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileInfo extends StatelessWidget {
  ProfileInfo({required this.userId});

  late int userId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: DefaultAppBar(title: 'Profile'),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(60)),
                child: Card(
                  shadowColor: Palette.lightOrange,
                  margin: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(60)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(160)),
                    topRight: Radius.circular(ScreenUtil().setWidth(160)),
                  )),
                  elevation: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: ScreenUtil().setHeight(350),
                            minWidth: ScreenUtil().setWidth(double.infinity)),
                        child: Card(
                          shadowColor: Palette.lightOrange,
                          child: UserData(userId: userId),
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(110))),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(40),
                      ),
                      UserInfoWidget(userId),
                      SizedBox(
                        height: ScreenUtil().setHeight(40),
                      ),
                      ReviewsListWidget(
                        userId: userId,
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

  Widget _dividerWidget() {
    return Container(
      width: ScreenUtil().setWidth(650.0),
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
        width: ScreenUtil().setWidth(80.0),
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
//          color: Palette.deepGrey,
          fontSize: ScreenUtil().setSp(45),
          fontWeight: FontWeight.w600),
    );
  }

  Widget _doubleTitle({required String title1,required String title2}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(title1, style: TextStyle(fontSize: ScreenUtil().setSp(45))),
        Text(title2, style: TextStyle(fontSize: ScreenUtil().setSp(45))),
      ],
    );
  }
}
