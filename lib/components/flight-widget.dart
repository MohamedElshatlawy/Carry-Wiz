import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Carrywiz/blocs/flight_details_bloc.dart';
import 'package:Carrywiz/data/airport/airport_lookup.dart';
import 'package:Carrywiz/components/flight_details_card.dart';

class FlightWidget extends StatelessWidget {
  FlightWidget({
   required this.airportLookup,
   required this.fromAirport,
   required this.toAirport,
  });
  final AirportLookup airportLookup;
  final String fromAirport;
  final String toAirport;

  Widget build(BuildContext context) {
    final flightDetailsBloc = Provider.of<FlightDetailsBloc>(context);
    return StreamBuilder<Flight>(
      stream: flightDetailsBloc.flightStream,
      initialData: Flight.initialData(),
      builder: (context, snapshot) {
        return Container(
          child: Column(
            children: <Widget>[
              FlightDetailsCard(
                airportLookup: airportLookup,
                flightDetails: snapshot.data!.details!,
                flightDetailsBloc: flightDetailsBloc,
                fromAirport: fromAirport,
                toAirport: toAirport,
              ),
            ],
          ),
        );
      },
    );
  }
}
