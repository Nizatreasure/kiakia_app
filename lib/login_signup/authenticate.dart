import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kiakia/login_signup/authenticate_home.dart';
import 'package:kiakia/login_signup/current_user_login.dart';
import 'package:kiakia/login_signup/login.dart';
import 'package:kiakia/login_signup/signup.dart';

class Authenticate extends StatefulWidget {
  final int id;
  final Map data;
  Authenticate({this.id, this.data});
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  int id;

  //responsible for changing the id
  void togglePages(int page) {
    setState(() {
      id = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    //decides whether to show the authentication home page, the sign up page or the log in page depending on the current id
    id = id == null ? widget.id : id;
    if (id == 1) return CurrentUserLoginPage(togglePage: togglePages, data: widget.data);
    if (id == 2) return LoginPage( togglePages);
    if (id == 3) return SignUp(togglePages);
    return AuthenticationHome(togglePages);
  }
}
