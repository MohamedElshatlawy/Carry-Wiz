import 'package:Carrywiz/injector/injector.dart';
import 'package:Carrywiz/utilities/SharedPreferencesManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreference {
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  setDarkTheme(bool value) async {
    await SharedPreferences.getInstance();
    _sharedPreferencesManager.putBool(
        SharedPreferencesManager.keyDarkMode, value);
  }

  Future<bool?> getTheme() async {
    return _sharedPreferencesManager
            .getBool(SharedPreferencesManager.keyDarkMode) ??
        false;
  }
}
