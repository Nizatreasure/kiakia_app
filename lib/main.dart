import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kiakia/login_signup/authenticate.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:kiakia/screens/dashboard.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  //initializes firebase functionality into the application
  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text(
            'Could not load data',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }

    //returns the application when flutterFire has been successfully initialized
    return MultiProvider(
      providers: [
        //this makes the user stream value available across all pages in the application
        StreamProvider<User>.value(
          value: AuthenticationService().user,
        ),
      ],

      //wraps the entire application to ensure that all textfields lose focus when the user taps on any non-clickable element
      child: GestureDetector(
        onTap: () {
          //removes focus from any currently focused textField when a user clicks on a whitespace
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild.unfocus();
          }
        },
        child: MaterialApp(
          home: Wrapper(),
          theme: ThemeData(
            primaryColor: Color(0xff0F7DBC),
          ),
        ),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //decides whether to show the home or sign in page depending on the information it receives from the user stream
    if (Provider.of<User>(context) == null &&
        FirebaseAuth.instance.currentUser == null) {
      return Authenticate();
    } else {
      return Dashboard();
    }
  }
}
