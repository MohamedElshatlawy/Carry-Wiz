import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/airport.dart';
import '../screens/carry-trip-screen.dart';
import '../screens/request-movement.dart';
import '../utilities/text-styles.dart';
import '../blocs/flight_details_bloc.dart';
import '../localization/language_constants.dart';
import '../data/airport/airport_lookup.dart';
import '../components/airport_search_delegate.dart';
import '../components/airport_widget.dart';
import '../utilities/vertical_spacing.dart';

class FlightDetailsCard extends StatefulWidget {
  final FlightDetailsBloc flightDetailsBloc;
  final AirportLookup airportLookup;
  final FlightDetails flightDetails;
  final String fromAirport;
  final String toAirport;

  FlightDetailsCard({
   required this.flightDetails,
   required this.flightDetailsBloc,
    required this.airportLookup,
   required this.fromAirport,
   required this.toAirport,
  });

  _FlightDetailsCardState createState() => _FlightDetailsCardState();
}

class _FlightDetailsCardState extends State<FlightDetailsCard> {
 late Airport _departureAirport;
 late Airport _arrivalAirport;

  Future<Airport?> _showSearch(BuildContext context) async {
    return await showSearch<Airport>(
        context: context,
        delegate: AirportSearchDelegate(
          airportLookup: widget.airportLookup,
        ));
  }

  void _selectDeparture(BuildContext context, FormFieldState state) async {
    final departure = await _showSearch(context);
    widget.flightDetailsBloc.updateWith(departure: departure);
    CarryTrip.departureAirport = departure!;
    RequestMovement.pickUpAirport = departure;
    setState(() {
      _departureAirport = departure;
      state.didChange(_departureAirport);
    });
  }

  void _selectArrival(BuildContext context, FormFieldState state) async {
    final arrival = await _showSearch(context);
    widget.flightDetailsBloc.updateWith(arrival: arrival);
    CarryTrip.arrivalAirport = arrival!;
    RequestMovement.dropOffAirport = arrival;
    setState(() {
      _arrivalAirport = arrival;
      state.didChange(_arrivalAirport);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Container(
        child: Column(
          children: <Widget>[
            FormField<Airport>(
              validator: (value) {
                if (value == null)
                  return getTranslatedValues(context, 'required_field');
                else
                  return null;
              },
              onSaved: (value) {
                _departureAirport = value!;
              },
              builder: (FormFieldState state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AirportWidget(
                      iconData: Icons.flight_takeoff,
                      title: Text('${widget.fromAirport}',
                          style: TextStyles.caption),
                      onPressed: () async => _selectDeparture(context, state),
                      airport: _departureAirport,
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style: TextStyle(
                            color: Colors.redAccent.shade700,
                            fontSize: ScreenUtil().setSp(40)),
                      )
                  ],
                );
              },
            ),
            defaultSizedBoxHeight,
            FormField<Airport>(
              validator: (value) {
                if (value == null)
                  return getTranslatedValues(context, 'required_field');
                else
                  return null;
              },
              onSaved: (value) {
                _arrivalAirport = value!;
              },
              builder: (FormFieldState state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AirportWidget(
                      iconData: Icons.flight_land,
                      title: Text('${widget.toAirport}',
                          style: TextStyles.caption),
                      onPressed: () => _selectArrival(context, state),
                      airport: _arrivalAirport,
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style: TextStyle(
                            color: Colors.redAccent.shade700,
                            fontSize: ScreenUtil().setSp(40)),
                      )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
