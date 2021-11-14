import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/airport.dart';
import '../localization/language_constants.dart';

class AirportWidget extends StatelessWidget {
  AirportWidget({
  required  this.iconData,
   required this.title,
  required  this.onPressed,
   required this.airport,
  });

  /// icon data to use (normally Icons.flight_takeoff or Icons.flight_land)
  final IconData iconData;

  /// Title to show
  final Widget title;

  /// Airport to show
  final Airport airport;

  /// Callback that fires when the user taps on this widget
  final VoidCallback onPressed;

  Airport get getAirport => airport;

  @override
  Widget build(BuildContext context) {
    final airportDisplayName = airport != null
        ? '${airport.iata}'
        : getTranslatedValues(context, 'select_airport');

    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            iconData,
//            color: Palette.deepPurple,
          ),
          SizedBox(width: ScreenUtil().setWidth(50)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                title,
                SizedBox(
                  height: ScreenUtil().setHeight(15),
                ),
                AutoSizeText(
                  airportDisplayName,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(50),
                      fontWeight: FontWeight.w500),
                  minFontSize: 16.0,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Divider(height: 2.0, color: Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
