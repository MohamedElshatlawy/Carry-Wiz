import 'dart:io';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../components/reviews-card.dart';
import '../models/Review.dart';
import '../models/ReviewResponseList.dart';
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../utilities/text-styles.dart';
import '../localization/language_constants.dart';

class ReviewsListWidget extends StatefulWidget {
  const ReviewsListWidget({required this.userId});
  final int userId;

  @override
  _ReviewsListWidgetState createState() => _ReviewsListWidgetState();
}

class _ReviewsListWidgetState extends State<ReviewsListWidget> {
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
  late Future<ReviewResponseList?> _reviewResponseList;

  @override
  void initState() {
    super.initState();
    try {
      _reviewResponseList =
          apiAuthProvider.getReviewResponseListByUserId(widget.userId);
    } on SocketException catch (e) {
      print(e);
    }
  }

  List<Review> _reviewsList = [];

  double calculateAvgRating() {
    return _reviewsList.fold(0.0, (sum, element) {
      return (sum + element.rating / _reviewsList.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[],
        ),
        FutureBuilder<ReviewResponseList?>(
            future: _reviewResponseList,
            builder: (context, AsyncSnapshot<ReviewResponseList?> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.none:
                  return SizedBox(
                    height: ScreenUtil().screenHeight / 1.3,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    String errorMessage = snapshot.error.toString();
                    var connectionStatus;
                    InternetConnectionChecker()
                        .connectionStatus
                        .then((value) => connectionStatus = value);

                    if (connectionStatus !=
                        InternetConnectionStatus.connected) {
                      errorMessage = 'Oops, you appear to be offline';
                    } else {
                      errorMessage = HttpNetWork.checkNetworkErrorString(
                          errorMessage, context);
                    }
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      child: Center(
                        child: Text(
                          'Error: $errorMessage',
                          style: TextStyles.errorStyle,
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data!.reviewResponseList.isEmpty) {
                      return Center(
                        child: Text(
                          getTranslatedValues(context, 'no_reviews'),
                          style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                        ),
                      );
                    } else
                      _reviewsList = snapshot.data!.reviewResponseList;
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(50),
                              vertical: ScreenUtil().setHeight(30)),
                          child: Row(
                            children: <Widget>[
                              _titleText(
                                  '${getTranslatedValues(context, 'reviews')} (${_reviewsList.length})'),
                              SizedBox(
                                width: ScreenUtil().setWidth(20),
                              ),
                              SmoothStarRating(
                                  allowHalfRating: true,
                                  starCount: 5,
                                  rating: calculateAvgRating(),
                                  size: ScreenUtil().setSp(55),
                                  filledIconData: Icons.star,
                                  halfFilledIconData: Icons.star_half,
                                  color: Colors.amber,
                                  borderColor: Colors.amber,
                                  spacing: 0.0),
                              SizedBox(
                                width: ScreenUtil().setWidth(20),
                              ),
                              Text(
                                '${calculateAvgRating().toString()}/5',
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40),
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ListView.builder(
                                primary: false,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: _reviewsList.length,
                                itemBuilder: (context, int index) {
                                  return ReviewsCard(_reviewsList[index]);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            })
      ],
    );
  }

  _titleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(
          //          color: Palette.deepGrey,
          fontSize: ScreenUtil().setSp(40),
          fontWeight: FontWeight.w600),
    );
  }
}
