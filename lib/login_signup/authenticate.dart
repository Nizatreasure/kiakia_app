import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kiakia/login_signup/authenticate_home.dart';
import 'package:kiakia/login_signup/login.dart';
import 'package:kiakia/login_signup/signup.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  int id;

  void togglePages(int page) {
    setState(() {
      id = page;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (id == 1) return LoginPage(togglePages);
    if (id == 2) return SignUp(togglePages);
    return AuthenticationHome(togglePages);
  }
}