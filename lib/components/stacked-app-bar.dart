import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StackedAppBar extends StatelessWidget {
  final double height;
  final String title;

  const StackedAppBar({required this.title, required this.height});

  @override
  Widget build(BuildContext context) {
//    ScreenUtil.init(context, allowFontScaling: true);
    return Stack(
      children: <Widget>[
        Container(
          decoration: new BoxDecoration(
//            color: Palette.deepPurple,
              ),
          height: height,
        ),
        AppBar(
          elevation: 20.0,
          centerTitle: true,
          title: Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(60)),
            child: Text(
              title,
              style: TextStyle(fontSize: ScreenUtil().setSp(60)),
            ),
          ),
          leading: IconButton(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(85)),
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
