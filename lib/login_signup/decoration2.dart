import 'package:flutter/material.dart';

//provides the decoration used in formatting text fields

final decoration2 = InputDecoration(
  errorStyle: TextStyle(fontSize: 14),
  hintStyle: TextStyle(
      color: Color.fromRGBO(81,83,82,0.5),
      fontSize: 17,
      fontWeight: FontWeight.w500),
  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(81, 83, 82, 1), width: 2)),
  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(81, 83, 82, 0.5))),
);
