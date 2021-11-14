import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:intl/intl.dart' as intl;
import '../models/Review.dart';
import '../themes/palette.dart';
import '../localization/language_constants.dart';

class ReviewsCard extends StatefulWidget {
  final Review review;

  ReviewsCard(
    this.review,
  );

  @override
  _ReviewsCardState createState() => _ReviewsCardState();
}

class _ReviewsCardState extends State<ReviewsCard> {
  bool isDirectionRTL(String text) {
    print('dir ${intl.Bidi.hasAnyRtl(text)}');
    return intl.Bidi.isRtlLanguage(text);
  }

  @override
  Widget build(BuildContext context) {
    final _sizedBoxDefaultHeight = SizedBox(
      height: ScreenUtil().setHeight(30),
    );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(80)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  rating: widget.review.rating,
                  size: ScreenUtil().setSp(45),
                  isReadOnly: true,
                  filledIconData: Icons.star,
                  halfFilledIconData: Icons.star_half,
                  color: Colors.amber,
                  borderColor: Colors.amber,
                  spacing: 0.0),
              Text(
                '   ${widget.review.rating}/5',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(40),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  child: Row(
                    children: <Widget>[
                      Text(
                        getTranslatedValues(context, 'by'),
                        style: TextStyle(
                            color: Palette.lightOrange,
                            fontSize: ScreenUtil().setSp(35),
                            fontWeight: FontWeight.bold),
                      ),
                      AutoSizeText(
                        '${widget.review.messageInfo.sender.name}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  'on ${intl.DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.review.messageInfo.createdAt.toString()))}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
            child: AutoSizeText(
              widget.review.reviewMessage,
              textDirection: isDirectionRTL(widget.review.reviewMessage)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              wrapWords: true,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40),
                  fontWeight: FontWeight.w500),
            ),
          ),
          _dividerWidget(),
        ],
      ),
    );
  }

  _titleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(
          color: Palette.lightPurple,
          fontSize: ScreenUtil().setSp(50),
          fontWeight: FontWeight.w600),
    );
  }

  _dividerWidget() {
    return Divider(
      thickness: ScreenUtil().setHeight(2),
      color: Colors.grey,
      height: ScreenUtil().setHeight(65),
    );
  }
}
