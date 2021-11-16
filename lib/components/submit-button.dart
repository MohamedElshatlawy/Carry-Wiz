import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubmitButton extends StatelessWidget {
  SubmitButton({
    required this.title,
//    @required this.height,
    required this.onPressed,
    required this.buttonColor,
  });

  /// Title to show
  final String title;

  /// Button Color
  final Color buttonColor;

  /// Callback that fires when the user taps on this widget
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
//    ScreenUtil.init(context, allowFontScaling: true);
    return ButtonTheme(
      height: ScreenUtil().setHeight(60),
      minWidth: double.infinity,
      child: FlatButton(
        onPressed: onPressed,
        textColor: Colors.white,
        color: buttonColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10),
        ),
        child: AutoSizeText(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(fontSize: ScreenUtil().setSp(20)),
        ),
      ),
    );
  }
}
