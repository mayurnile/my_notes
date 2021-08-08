import 'package:flutter/material.dart';

class MyNotesTheme {
  //colors
  static const Color primaryColor = Color(0xFFFBB96A);
  static const Color fontDarkColor = Color(0xFF000000);
  static const Color fontLightColor = Color(0xFFC0C0C0);
  static const Color cardColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFDA291C);

  static ThemeData getMyNotesThemeData() {
    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: primaryColor,
      accentColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Nunito',
      accentIconTheme: const IconThemeData(
        color: primaryColor,
      ),
      indicatorColor: primaryColor,
      iconTheme: const IconThemeData(
        color: primaryColor,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: fontDarkColor,
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(
          fontSize: 36.0,
          fontWeight: FontWeight.w800,
          color: fontDarkColor,
        ),
        headline2: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
          color: fontDarkColor,
        ),
        headline3: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w300,
          color: fontLightColor,
        ),
        headline4: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
          color: fontDarkColor,
        ),
        headline5: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: fontLightColor,
        ),
        headline6: TextStyle(
          fontSize: 9.0,
          fontWeight: FontWeight.w300,
          color: fontLightColor,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0.0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }
}
