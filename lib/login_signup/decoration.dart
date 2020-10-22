import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//provides the decoration used in formatting the signUp and login text fields

final decoration = InputDecoration(
  floatingLabelBehavior: FloatingLabelBehavior.always,
  labelStyle: TextStyle(
    height: 3,
    color: Color.fromRGBO(100, 120, 140, 1),
    fontSize:20, fontWeight: FontWeight.w500,
  ),
  errorStyle: TextStyle(fontSize: 14),
  hintStyle: TextStyle(color:Color.fromRGBO(138, 136, 136, 1), fontSize: 18, fontWeight: FontWeight.w500 ),
  filled: true,
  fillColor: Color.fromRGBO(244, 246, 248, 1),
  focusColor: Colors.red,
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  ),
);