import 'package:Carrywiz/models/airport.dart';
import 'package:Carrywiz/data/airport/airport_data_reader.dart';

class AirportLookup {
  AirportLookup({this.airports});
  final List<Airport>? airports;

  List<Airport>? airportsList;

  void getAirports() async {
    final start = DateTime.now();
    airportsList = await AirportDataReader.load('assets/data/airports.dat');
    final elapsed = DateTime.now().difference(start);
    print('Loaded airports data in $elapsed');
  }

  Airport searchIata(String iata) {
    return airportsList!.firstWhere((airport) => airport.iata == iata);
  }

  List<Airport> searchString(String string) {
    string = string.toLowerCase();
    final matching = airportsList!.where((airport) {
      final iata = airport.iata ?? '';
      return iata.toLowerCase() == string ||
          airport.name!.toLowerCase() == string ||
          airport.city!.toLowerCase() == string ||
          airport.country!.toLowerCase() == string;
    }).toList();
    // found exact matches
    if (matching.length > 0) {
      return matching;
    }
    // search again with less strict criteria
    return airportsList!.where((airport) {
      final iata = airport.iata ?? '';
      return iata.toLowerCase().contains(string) ||
          airport.name!.toLowerCase().contains(string) ||
          airport.city!.toLowerCase().contains(string) ||
          airport.country!.toLowerCase().contains(string);
    }).toList();
  }
}
