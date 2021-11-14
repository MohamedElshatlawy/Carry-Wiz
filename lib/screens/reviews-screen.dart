import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/default-app-bar-widget.dart';
import 'reviews-list-screen.dart';
import '../localization/language_constants.dart';

class ReviewsScreen extends StatelessWidget {
  ReviewsScreen({required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: DefaultAppBar(
          title: getTranslatedValues(context, 'reviews'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: ScreenUtil().setHeight(50),
              ),
              ReviewsListWidget(
                userId: userId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
