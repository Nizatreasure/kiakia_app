import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  primaryColor: Colors.white,
  buttonColor: Color.fromRGBO(15, 125, 188, 1),
  textTheme: TextTheme(
      bodyText1: TextStyle(),
      bodyText2: TextStyle(),
      button: TextStyle(
          color: Color.fromRGBO(246, 248, 250, 1),
          fontSize: 18,
          fontWeight: FontWeight.w600)),
  accentColor: Color.fromRGBO(77, 172, 246, 1),
);
