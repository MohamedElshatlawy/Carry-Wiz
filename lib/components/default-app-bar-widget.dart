import 'package:Carrywiz/screens/settings-screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const DefaultAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AutoSizeText(
        title,
        style: TextStyle(fontSize: ScreenUtil().setSp(20)),
      ),
      toolbarHeight: ScreenUtil().setHeight(50),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        if (title != 'Settings' || title != 'الأعدادات')
          IconButton(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
            icon: Icon(
              Icons.brightness_low,
              size: ScreenUtil().setSp(20),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(ScreenUtil().setHeight(50));
}
