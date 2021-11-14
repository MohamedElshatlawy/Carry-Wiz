import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../provider/KilosCounterProvider.dart';
import '../localization/language_constants.dart';

class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var counter = Provider.of<KilosCounterProvider>(context);
    return Row(
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.exposure_neg_1,
              size: ScreenUtil().setSp(80),
            ),
            onPressed: () => counter.decreaseCounter()),
        Text(
          '${counter.kilos} ${getTranslatedValues(context, 'kg')}',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(70),
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.exposure_plus_1,
            size: ScreenUtil().setSp(80),
          ),
          onPressed: () => counter.incrementCounter(),
        ),
      ],
    );
  }
}
