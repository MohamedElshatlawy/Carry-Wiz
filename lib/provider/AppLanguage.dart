import 'package:Carrywiz/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale(ENGLISH_CODE);

  Locale get appLocal => _appLocale;

 Future<Locale> fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('languageCode') == null) {
      _appLocale = Locale(ENGLISH_CODE);
      return _appLocale;
    }
    _appLocale = Locale(prefs.getString('languageCode')!);
    return _appLocale;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale(ARABIC_CODE)) {
      _appLocale = Locale(ARABIC_CODE);
      await prefs.setString('languageCode', ARABIC_CODE);
      await prefs.setString('countryCode', ARABIC_COUNTRY_CODE);
    } else {
      _appLocale = Locale(ENGLISH_CODE);
      await prefs.setString('languageCode', ENGLISH_CODE);
      await prefs.setString('countryCode', ENGLISH_COUNTRY_CODE);
    }
    notifyListeners();
  }
}
