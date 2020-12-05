import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  primaryColor: Colors.white,
  buttonColor: Color.fromRGBO(57,138,239,1),
  splashColor: Colors.transparent,
  textTheme: TextTheme(
      bodyText1: TextStyle(),
      bodyText2: TextStyle(
          color: Color.fromRGBO(81, 83, 82, 1),
          fontSize: 16,
          fontWeight: FontWeight.w400),
      button: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 18,
          fontWeight: FontWeight.w600)),
  accentColor: Color.fromRGBO(77, 172, 246, 1),
);
