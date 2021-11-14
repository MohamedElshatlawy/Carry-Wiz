import 'package:Carrywiz/screens/settings-screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarWidget extends StatelessWidget implements PreferredSize {
  final String title;

  const AppBarWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry _topPadding =
        EdgeInsets.only(top: ScreenUtil().setHeight(80));
    return PreferredSize(
      preferredSize: Size.fromHeight(ScreenUtil().setHeight(300)),
      child: AppBar(
        title: Padding(
          padding: _topPadding,
          child: Text(
            title,
            style: TextStyle(fontSize: ScreenUtil().setSp(60)),
          ),
        ),
        centerTitle: true,
//        backgroundColor: Palette.deepPurple,
//        leading: IconButton(
//          padding: _topPadding,
//          icon: Icon(Icons.arrow_back_ios),
//          onPressed: () {
//            Navigator.of(context).pop();
//          },
//        ),
        actions: <Widget>[
          IconButton(
            padding: _topPadding,
            icon: Icon(Icons.brightness_low),
            onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(ScreenUtil().setHeight(250));

  @override
  // TODO: implement child
  Widget get child => throw UnimplementedError();


}
