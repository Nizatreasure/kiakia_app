import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentBottomNavigationBarIndex = 0;
  List<String> _navigationBarTitle = [
    'Dashboard',
    'Order',
    'Wallet',
    'Settings'
  ];
  StreamSubscription<Event> userDataStream;
  Map snapshot;

  void setCurrentNavigationBarIndex() {
    //moves the bottom navigation bar to the order page
    setState(() {
      _currentBottomNavigationBarIndex = 1;
    });
  }

  _initializeTime() async {
    await TimeMachine.initialize({'rootBundle': rootBundle});
  }

  _saveUserDataToStorage ({name, email, number, status}) { //saves user information to their local storage
    Map<String, dynamic> userData = new Map();
    userData['name'] = name;
    userData['email'] = email;
    userData['number'] = number;
    userData['status'] = status;
    storage.setItem('userData', userData);
//    storage.setItem('name', name);
//    storage.setItem('number', number);
//    storage.setItem('email', email);
//    storage.setItem('status', status);
  }

  //gets the user information from the database, listens for changes in the data and stores it locally
  getUserInformation() {
    final uid = FirebaseAuth.instance.currentUser.uid;
    final DatabaseReference database = FirebaseDatabase.instance.reference();
    userDataStream = database.child('users').child(uid).onValue.listen((event) {
      Map snap = event.snapshot.value;
      if (snap.isNotEmpty) {
        _saveUserDataToStorage(name: snap['name'], email: snap['email'], number: snap['number'], status: snap['isNumberVerified']);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeTime();
    getUserInformation();
  }

  @override
  void dispose() {
    super.dispose();
    if (userDataStream != null) userDataStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _bottomNavigationBarItemBody = [
      Home(setCurrentNavigationBarIndex),
      Order(),
      Container(),
      Container(),
    ];
    return Scaffold(
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
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: MyDrawer(snapshot),
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
    );
  }
}
