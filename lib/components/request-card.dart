import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/NetworkSensitive.dart';
import '../components/submit-button.dart';
import '../screens/DetailScreen.dart';
import '../models/RequestCarry.dart';
import '../services/ApiAuthProvider.dart';
import '../themes/palette.dart';
import '../localization/language_constants.dart';

class RequestCard extends StatelessWidget {
  final RequestCarry requestCarry;
  final String? leftButtonTitle;
  final String rightButtonTitle;
  final VoidCallback? leftButtonCallback;
  final VoidCallback rightButtonCallback;
  final Color? oneButtonColor;

  RequestCard({
    required this.requestCarry,
    this.leftButtonTitle,
    required this.rightButtonTitle,
    this.leftButtonCallback,
   this.oneButtonColor,
    required this.rightButtonCallback,
  });

  final ApiAuthProvider apiAuthProvider = ApiAuthProvider();

  @override
  Widget build(BuildContext context) {
    //TODO: merge with carries card
    final _sizedBoxDefaultHeight = SizedBox(
      height: ScreenUtil().setHeight(20),
    );
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(60),
          vertical: ScreenUtil().setHeight(25)),
      elevation: 5,
      shadowColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey
          : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: ExpandablePanel(
        theme: ExpandableThemeData(
            iconColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey
                : Colors.white),
        header: RequestCarryInfo(
          requestCarry: requestCarry,
        ),
        expanded: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(50)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _requestCarryDetails(
                  leftTitle: getTranslatedValues(context, 'pickup_airport'),
                  leftValue: requestCarry.pickupAirport!.iata,
                  rightTitle: getTranslatedValues(context, 'dropoff_airport'),
                  rightValue: requestCarry.dropOffAirport!.iata),
              _sizedBoxDefaultHeight,
              _requestCarryDetails(
                  leftTitle: getTranslatedValues(context, 'package_width'),
                  leftValue: requestCarry.packageWidth.toString(),
                  rightTitle: getTranslatedValues(context, 'package_height'),
                  rightValue: requestCarry.packageHeight.toString()),
              _sizedBoxDefaultHeight,
              _titleText(getTranslatedValues(context, 'preferred_time')),
              _sizedBoxDefaultHeight,
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
                child: Text(
                  requestCarry.requestTime!,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(50),
                      fontWeight: FontWeight.w700),
                ),
              ),
              _sizedBoxDefaultHeight,
              _titleText(getTranslatedValues(context, 'preferred_location')),
              _sizedBoxDefaultHeight,
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
                child: Text(
                  requestCarry.pickUpLocation!,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(50),
                      fontWeight: FontWeight.w700),
                ),
              ),
              _sizedBoxDefaultHeight,
              (requestCarry.requestDetailsText == '' ||
                      requestCarry.requestDetailsText == null)
                  ? Text('')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _titleText(
                            getTranslatedValues(context, 'request_details')),
                        Container(
                            width: ScreenUtil().setWidth(900),
                            child: AutoSizeText(
                              '    ${requestCarry.requestDetailsText}',
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(45)),
                            ))
                      ],
                    ),
              leftButtonTitle == null
                  ? NetworkSensitive(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(150),
                            vertical: ScreenUtil().setWidth(30)),
                        child: SubmitButton(
                          buttonColor: oneButtonColor!,
                          onPressed: () => rightButtonCallback(),
                          title: rightButtonTitle,
                        ),
                      ),
                    )
                  : NetworkSensitive(
                      child: Row(
                        children: <Widget>[
                          _expandedButtons(leftButtonTitle!, Colors.amber,
                              leftButtonCallback!),
                          _expandedButtons(rightButtonTitle, Colors.red,
                              rightButtonCallback),
                        ],
                      ),
                    )
            ],
          ),
        ), collapsed: Text(''),
      ),
    );
  }

  _requestCarryDetails(
      {required String leftTitle,
      required String rightTitle,
      dynamic leftValue,
      dynamic rightValue}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: <Widget>[
            _titleText(leftTitle),
            Text(leftValue,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    fontWeight: FontWeight.w700)),
          ],
        ),
        SizedBox(
          height: ScreenUtil().setHeight(20),
        ),
        Column(
          children: <Widget>[
            _titleText(rightTitle),
            Text(rightValue,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  _expandedButtons(String title, Color color, VoidCallback function) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(20),
        child: SubmitButton(
          buttonColor: color,
          onPressed: () => function(),
          title: title,
        ),
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
}

class RequestCarryInfo extends StatelessWidget {
  final RequestCarry requestCarry;

  const RequestCarryInfo({required this.requestCarry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setHeight(60),
              vertical: ScreenUtil().setHeight(30)),
          child: Container(
            width: ScreenUtil().setWidth(200),
            height: ScreenUtil().setHeight(200),
            child: (requestCarry.requestImageURL != null)
                ? GestureDetector(
                    child: Hero(
                        tag: 'Package image ${requestCarry.requestCarryId}',
                        child: Image.network(
                          requestCarry.requestImageURL!,
                        )),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return DetailScreen(
                          imageURL: requestCarry.requestImageURL,
                        );
                      }));
                    },
                  )
                : Image.asset(
                    'assets/images/request_list/${requestCarry.shippingType!.toLowerCase()}.png',
                    fit: BoxFit.fill,
                    color: Theme.of(context).textTheme.bodyText2!.color,
                  ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AutoSizeText(
              '${requestCarry.pickupAirport!.iata} - ${requestCarry.dropOffAirport!.iata}',
              style: TextStyle(
                  color: Palette.lightGreen,
                  fontSize: ScreenUtil().setSp(50),
                  fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: ScreenUtil().setHeight(11),
            ),
            AutoSizeText(
              '${requestCarry.requestDate}',
              style: TextStyle(
//                          color: Palette.deepPurple,
                  fontSize: ScreenUtil().setSp(45),
                  fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: ScreenUtil().setHeight(11),
            ),
            AutoSizeText(
              '${getTranslatedValues(context, 'luggage')} - ${requestCarry.kilos} ${getTranslatedValues(context, 'kg')}',
              style: TextStyle(
//                          color: Palette.deepPurple,
                  fontSize: ScreenUtil().setSp(45),
                  fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
