import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../localization/language_constants.dart';

class PageNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          getTranslatedValues(context, 'page_not_found'),
          style: TextStyle(fontSize: ScreenUtil().setSp(80), color: Colors.red),
        ),
      ),
    );
  }
}
