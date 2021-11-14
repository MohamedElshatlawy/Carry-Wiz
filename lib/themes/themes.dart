import '../themes/palette.dart';
import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primaryColor: Palette.deepPurple,
      accentColor: isDarkTheme ? Colors.amber : Colors.deepPurple,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: Colors.white),
      ),
//      backgroundColor: isDarkTheme ? Palette.darkPurple : Colors.white,
      primaryTextTheme: TextTheme(
          button:
              TextStyle(color: isDarkTheme ? Colors.white : Colors.deepPurple)),
//      indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      buttonColor: isDarkTheme ? Colors.deepPurple : Colors.white,
//      hintColor: isDarkTheme ? Color(0xff280C0B) : Color(0xffEECED3),
      highlightColor: isDarkTheme ? Color(0xff372901) : Color(0xffFCE192),
      hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xff4285F4),
      focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.redAccent,
      cardTheme:
          CardTheme(color: isDarkTheme ? Palette.darkPurple : Colors.white),
      canvasColor: isDarkTheme ? Palette.deepPurple : Colors.white,
      textTheme: TextTheme(
        bodyText1:
            TextStyle(color: isDarkTheme ? Colors.white : Palette.deepPurple),
        bodyText2: TextStyle(color: Colors.blue),
        overline: TextStyle(color: Colors.redAccent),
        headline1: TextStyle(
            color: isDarkTheme
                ? Colors.white
                : Palette.deepPurple), // to change text inside TextField
      ),

      brightness: isDarkTheme ? Brightness.dark : Brightness.light,

      buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.accent,
          colorScheme: isDarkTheme
              ? ColorScheme.dark(primary: Palette.deepPurple)
              : ColorScheme.light(primary: Colors.white)), // Text color
      appBarTheme: AppBarTheme(
        elevation: 10.0,
      ),
    );
  }
}
