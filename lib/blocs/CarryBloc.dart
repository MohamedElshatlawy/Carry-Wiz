
import 'package:flutter/cupertino.dart';

class CarryBloc extends ChangeNotifier {

  int? _departureAirportId;

  int? _arrivalAirportId;

  int get departureAirportId => _departureAirportId!;
  
  int get arrivalAirportId => _arrivalAirportId!;

  set departureAirportId(int value) {
    _departureAirportId = value;
    notifyListeners();
  }

    set arrivalAirportId(int value) {
    _arrivalAirportId = value;
    notifyListeners();
  }

}
