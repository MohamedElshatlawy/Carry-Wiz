import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Carrywiz/localization/AppLocalizations.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH_CODE = 'en';
const String ARABIC_CODE = 'ar';

const String ENGLISH_COUNTRY_CODE = 'US';
const String ARABIC_COUNTRY_CODE = 'EG';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? ENGLISH_CODE;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH_CODE:
      return Locale(ENGLISH_CODE, ENGLISH_COUNTRY_CODE);
    case ARABIC_CODE:
      return Locale(ARABIC_CODE, ARABIC_COUNTRY_CODE);
    default:
      return Locale(ENGLISH_CODE, ENGLISH_COUNTRY_CODE);
  }
}

String getTranslatedValues(BuildContext context, String key) {
  return AppLocalizations.of(context).translate(key);
}
