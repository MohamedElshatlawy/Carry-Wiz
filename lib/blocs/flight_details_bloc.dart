import '../models/airport.dart';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';

/// Model for the FlightDetailsCard
class FlightDetails {
  FlightDetails({
    this.departure,
    this.arrival,
  });
  Airport? departure;
  Airport? arrival;

  FlightDetails copyWith({
    Airport? departure,
    Airport? arrival,
  }) {
    return FlightDetails(
      departure: departure,
      arrival: arrival,
    );
  }
}

// Model for the FlightPage
class Flight {
  Flight({
    required this.details,
  });
  final FlightDetails? details;
//  final FlightData data;

  /// Initial empty data to be used as the seed value for the stream
  factory Flight.initialData() {
    return Flight(
      details: FlightDetails(),
//      data: FlightData(),
    );
  }

  Flight copyWith({
    Airport? departure,
    Airport? arrival,
  }) {
    // get existing details and update
    FlightDetails flightDetails = details!.copyWith(
      departure: departure,
      arrival: arrival,
    );
    // calculate corresponding data
//    FlightData flightData = FlightData.fromDetails(flightDetails);
    // return new object
    return Flight(
      details: flightDetails,
//      data: flightData,
    );
  }
}

/// Bloc used by the FlightPage
class FlightDetailsBloc {
  BehaviorSubject _flightSubject =
      BehaviorSubject<Flight>.seeded(Flight.initialData());

  var flightStream;
  // Stream<Flight> get flightStream => _flightSubject.controller.stream;

  void updateWith({
    Airport? departure,
    Airport? arrival,
  }) {
    // get new value by updating existing one
    Flight newValue = _flightSubject.value.copyWith(
      departure: departure,
      arrival: arrival,
    );
    // add back to the stream
    _flightSubject.add(newValue);
  }

  dispose() {
    _flightSubject.close();
  }
}
