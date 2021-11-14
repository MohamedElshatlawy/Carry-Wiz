import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BodyCard extends StatelessWidget {
  @required
  final Widget widget;
  @required
  final double topPadding;
  @required
  final double bottomPadding;
  @required
  final double leftPadding;
  @required
  final double rightPadding;
  const BodyCard(
      {required this.widget,
      required this.topPadding,
      required this.bottomPadding,
      required this.leftPadding,
      required this.rightPadding});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(
            vertical: ScreenUtil().setHeight(50),
            horizontal: ScreenUtil().setWidth(60)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: EdgeInsets.only(
              top: ScreenUtil().setHeight(topPadding),
              bottom: ScreenUtil().setHeight(bottomPadding),
              left: ScreenUtil().setWidth(leftPadding),
              right: ScreenUtil().setWidth(rightPadding)),
          child: widget,
        ),
      ),
    );
  }
}
