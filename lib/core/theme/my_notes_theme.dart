import 'package:flutter/material.dart';

class MyNotesTheme {
  //colors
  static const Color PRIMARY_COLOR = Color(0xFFFBB96A);
  static const Color FONT_DARK_COLOR = Color(0xFF000000);
  static const Color FONT_LIGHT_COLOR = Color(0XFFC0C0C0);
  static const Color CARD_COLOR = Color(0xFFF5F5F5);
  static const Color ERROR_COLOR = Color(0xFFDA291C);

  static ThemeData myNotesThemeData = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: PRIMARY_COLOR,
    accentColor: PRIMARY_COLOR,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Nunito',
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 36.0,
        fontWeight: FontWeight.w800,
        color: FONT_DARK_COLOR,
      ),
      headline2: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: FONT_DARK_COLOR,
      ),
      headline3: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w300,
        color: FONT_LIGHT_COLOR,
      ),
      headline4: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        color: FONT_DARK_COLOR,
      ),
      headline5: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: FONT_LIGHT_COLOR,
      ),
      headline6: TextStyle(
        fontSize: 9.0,
        fontWeight: FontWeight.w300,
        color: FONT_LIGHT_COLOR,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: PRIMARY_COLOR,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
  );
}
