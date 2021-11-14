import 'package:flutter/material.dart';

class KilosCounterProvider with ChangeNotifier {
  int kilos = 1;

  incrementCounter() {
    if (kilos < 30) {
      kilos++;
      notifyListeners();
    }
  }

  decreaseCounter() {
    if (kilos > 1) {
      kilos--;
      notifyListeners();
    }
  }
}
