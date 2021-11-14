import 'package:Carrywiz/themes/palette.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CountNumberFuture extends StatelessWidget {
  const CountNumberFuture({
    required Future<int> countNumber,
  })  : countNumber = countNumber;

  final Future<int> countNumber;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: countNumber,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AutoSizeText(
            '${snapshot.data}',
            style: TextStyle(
                color: Palette.deepPurple,
                fontSize: ScreenUtil().setSp(60),
                fontWeight: FontWeight.w500),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }
}
