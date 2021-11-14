import 'package:Carrywiz/services/ApiAuthProvider.dart';
import 'package:Carrywiz/utilities/text-styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PackageRequestCard extends StatefulWidget {
  final Widget? cardWidget;
  final bool isRead;
  final String? messageTitle;
  final VoidCallback? actionButtonVoidCallBack;
  final Widget? actionWidget;
  final Function onTapFunction;

  PackageRequestCard({
    required this.isRead,
    this.messageTitle,
    required this.onTapFunction,
    this.actionButtonVoidCallBack,
    this.actionWidget,
    this.cardWidget,
  });

  @override
  _PackageRequestCardState createState() => _PackageRequestCardState();
}

class _PackageRequestCardState extends State<PackageRequestCard> {
  final ApiAuthProvider apiAuthProvider = ApiAuthProvider();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.isRead ? null : widget.onTapFunction(),
      child: Card(
        elevation: 6.0,
        margin: EdgeInsets.symmetric(
            vertical: ScreenUtil().setHeight(25),
            horizontal: ScreenUtil().setHeight(15)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: widget.actionWidget == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceAround,
              children: <Widget>[
                if (!widget.isRead)
                  Icon(
                    Icons.brightness_1,
                    color: Colors.red,
                    size: ScreenUtil().setSp(25),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                  child: Text(
                    widget.messageTitle!,
                    style: TextStyles.expandedTitleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: ScreenUtil().setWidth(70),
                      top: ScreenUtil().setHeight(20)),
                  width: ScreenUtil().setWidth(90),
                  height: ScreenUtil().setHeight(90),
                  child: FlatButton(
                    onPressed: () => widget.actionButtonVoidCallBack!(),
                    padding: EdgeInsets.all(0.0),
                    child: widget.actionWidget!,
                  ),
                ),
              ],
            ),
            widget.cardWidget!,
          ],
        ),
      ),
    );
  }
}
