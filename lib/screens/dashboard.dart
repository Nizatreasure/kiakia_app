import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kiakia/login_signup/login.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:kiakia/login_signup/services/change_user_number.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/home.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/order.dart';
import 'package:kiakia/screens/drawer.dart';
import 'package:localstorage/localstorage.dart';
import 'package:time_machine/time_machine.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  AuthenticationService _auth = AuthenticationService();
  final storage = new LocalStorage('user_data.json');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentBottomNavigationBarIndex = 0;
  String photoURL;
  List<String> _navigationBarTitle = [
    'Dashboard',
    'Order',
    'Wallet',
    'Settings'
  ];
  StreamSubscription<Event> userDataStream;

  //moves the bottom navigation bar to the order page
  void setCurrentNavigationBarIndex() {
    setState(() {
      _currentBottomNavigationBarIndex = 1;
    });
  }


  _initializeTime() async {
    await TimeMachine.initialize({'rootBundle': rootBundle});
  }

  //saves user information to their local storage
  _saveUserDataToStorage({name, email, number, status, provider}) async {
    Map<String, dynamic> userData = new Map();
    userData['name'] = name;
    userData['email'] = email;
    userData['number'] = number;
    userData['status'] = status;
    userData['provider'] = provider;
    await storage.ready;
    storage.setItem('userData', userData);
  }

  //gets the user information from the database, listens for changes in the data and stores it locally
  _getUserInformation() async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    final DatabaseReference database = FirebaseDatabase.instance.reference();
    userDataStream =
        database.child('users').child(uid).onValue.listen((event) async {
      Map snap = event.snapshot.value;
      if (snap.isNotEmpty) {
        photoURL = snap['pictureURL'];
        _saveUserDataToStorage(
          name: snap['name'],
          email: snap['email'],
          number: snap['number'],
          status: snap['isNumberVerified'],
          provider: snap['provider'],
        );
      }
      if (mounted) {
        _saveDeviceToken();
        setState(() {});
      }
    });
  }

  //this function is called from the homepage and gives the context
  // of the dashboard to the numberNotVerifiedPopup function
  void showNumberNotVerified(number) {
    numberNotVerifiedPopup(number, context);
  }

  //prompts users who have not entered their phone numbers to enter it.
  // this is done here to have a wide context
  void registerUserNumber() {
    changeUserNumber(context,
        'Phone number not linked with this account. Please enter your number');
  }

  //saves the unique device token to firebase
  _saveDeviceToken() async {
    String id = FirebaseAuth.instance.currentUser.uid;
    String token = await _firebaseMessaging.getToken();
    if (token != null) {
      await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(id)
          .update({'token': token});
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeTime();
    _getUserInformation();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    }, onLaunch: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    }, onResume: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (userDataStream != null) userDataStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _bottomNavigationBarItemBody = [
      Home(setCurrentNavigationBarIndex, showNumberNotVerified,
          registerUserNumber),
      Order(),
      Container(),
      Container(),
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 500),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xffffffff),
        appBar: AppBar(
          leading: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlatButton.icon(
                icon: Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 16,
                ),
                onPressed: () async {
                  await _auth.logOut();
                },
                label: Text(
                  'Logout',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                ),
              ),
            )
          ],
          backgroundColor: Color(0xffffffff),
          title: Text(
            _navigationBarTitle[_currentBottomNavigationBarIndex],
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        drawer: MyDrawer(
                photoURL: photoURL,
              ),
        body: _bottomNavigationBarItemBody[_currentBottomNavigationBarIndex],
        bottomNavigationBar: BottomNavigationBar(
            unselectedItemColor: Color.fromRGBO(166, 170, 180, 1),
            selectedItemColor: Color.fromRGBO(77, 172, 246, 1),
            showUnselectedLabels: true,
            currentIndex: _currentBottomNavigationBarIndex,
            onTap: (index) {
              setState(() {
                _currentBottomNavigationBarIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_books), label: 'Order'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card), label: 'Wallet'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings')
            ]),
      ),
    );
  }
}
