import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/NetworkSensitive.dart';
import '../components/submit-button.dart';
import '../models/Carry.dart';
import '../localization/language_constants.dart';
import '../themes/palette.dart';

class CarryCard extends StatelessWidget {
  final Carry carry;
  final String? leftButtonTitle;
  final String rightButtonTitle;
  final VoidCallback? leftButtonCallback;
  final VoidCallback rightButtonCallback;
  final bool isExpanded;

  CarryCard({
    required this.carry,
    this.leftButtonTitle,
    required this.rightButtonTitle,
    this.leftButtonCallback,
    required this.rightButtonCallback,
    required this.isExpanded,
  });

  ExpandableController _expandableController = ExpandableController();

  void _expand() {
    _expandableController.expanded = true;
  }

  @override
  Widget build(BuildContext context) {
    if (isExpanded) _expand();
    final _sizedBoxDefaultHeight = SizedBox(
      height: ScreenUtil().setHeight(30),
    );

    return Card(
      elevation: 5.0,
      shadowColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey
          : Colors.white,
      margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(55),
          vertical: ScreenUtil().setHeight(25)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setHeight(60),
            vertical: ScreenUtil().setHeight(15)),
        child: ExpandablePanel(
          theme: ExpandableThemeData(
              iconColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Colors.white),
          header: ExpandableCarryHeader(
            carry: carry,
          ),
          controller: _expandableController,
          expanded: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _titleText(getTranslatedValues(context, 'pickup_airport')),
                  _titleText(getTranslatedValues(context, 'dropoff_airport')),
                ],
              ),
              SizedBox(
                height: ScreenUtil().setHeight(20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('${carry.departureAirport.iata}',
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(70),
                          fontWeight: FontWeight.w700)),
//                      _dividerWidget(),
                  Text('${carry.arrivalAirport.iata}',
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(70),
                          fontWeight: FontWeight.w700)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _titleText(getTranslatedValues(context, 'departure_date')),
                  _titleText(getTranslatedValues(context, 'return_date')),
                ],
              ),
              _sizedBoxDefaultHeight,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  AutoSizeText(
                    '${carry.departureDate}',
                    style: TextStyle(
//                                color: Palette.deepPurple,
                        fontSize: ScreenUtil().setSp(45),
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  AutoSizeText(
                    '${carry.returnDate}',
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(45),
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              _sizedBoxDefaultHeight,
              _titleText(
                  getTranslatedValues(context, 'available_shipping_type')),
              Row(
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(800),
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    height: ScreenUtil().setHeight(80),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: carry.shippingTypes!.length,
                      itemBuilder: (context, shippingTypeIndex) {
                        return Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil().setHeight(20),
                                  right: ScreenUtil().setHeight(10)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(15),
                                  vertical: ScreenUtil().setHeight(8)),
                              child: AutoSizeText(
                                carry.shippingTypes!
                                    .elementAt(shippingTypeIndex),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(12),
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.left,
                                minFontSize: 13.0,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              decoration: BoxDecoration(
                                  color: Palette.lightViolet,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              _titleText(getTranslatedValues(context, 'preferred_time')),
              _sizedBoxDefaultHeight,
              Text(
                carry.deliveryTime!,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    fontWeight: FontWeight.w700),
              ),
              _sizedBoxDefaultHeight,
              _titleText(getTranslatedValues(context, 'preferred_location')),
              _sizedBoxDefaultHeight,
              Text(
                carry.deliveryLocation!,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    fontWeight: FontWeight.w700),
              ),
              leftButtonTitle != null
                  ? NetworkSensitive(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(ScreenUtil().setWidth(50)),
                              child: SubmitButton(
                                buttonColor: Colors.amber,
                                onPressed: () => leftButtonCallback!(),
                                title: '$leftButtonTitle',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(20),
                              child: SubmitButton(
                                buttonColor: Colors.red,
                                onPressed: () => rightButtonCallback(),
                                title: '$rightButtonTitle',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : NetworkSensitive(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(150),
                            vertical: ScreenUtil().setWidth(30)),
                        child: SubmitButton(
                          buttonColor: Colors.red,
                          title: rightButtonTitle,
                          onPressed: () => rightButtonCallback(),
                        ),
                      ),
                    )
            ],
          ),
          collapsed: Text(
            carry.departureDate,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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

class ExpandableCarryHeader extends StatelessWidget {
  const ExpandableCarryHeader({
    required this.carry,
  });

  final Carry carry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setHeight(60),
              vertical: ScreenUtil().setHeight(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AutoSizeText(
                DateFormat('dd').format(DateTime.parse(carry.returnDate)),
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis,
              ),
              AutoSizeText(
                DateFormat('MMM').format(DateTime.parse(carry.returnDate)),
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setHeight(20),
              vertical: ScreenUtil().setHeight(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(
                '${carry.departureAirport.iata} - ${carry.arrivalAirport.iata}',
                style: TextStyle(
                    color: Palette.lightOrange,
                    fontSize: ScreenUtil().setSp(50),
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: ScreenUtil().setHeight(11),
              ),
              AutoSizeText(
                '${carry.returnDate}',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(45),
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
              AutoSizeText(
                '${getTranslatedValues(context, 'space')} - ${carry.kilos} ${getTranslatedValues(context, 'kg')}',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(45),
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
