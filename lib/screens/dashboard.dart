import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kiakia/drawer/drawer.dart';
import 'package:kiakia/login_signup/authenticate.dart';
import 'package:kiakia/login_signup/services/change_user_number.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/home.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/order.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/profile.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final storage = new LocalStorage('user_data.json');
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentBottomNavigationBarIndex = 0;
  String photoURL;
  Map snap;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<String> _navigationBarTitle = ['Dashboard', 'Order', 'Profile'];
  StreamSubscription<Event> userDataStream,
      gasLevelStream,
      userDeleteSubscription;
  double value; //the amount of gas left in the cylinder of the user

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
      snap = event.snapshot.value;
      if (snap != null && snap.isNotEmpty) {
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

  Future logout() async {
    await storage.ready;
    Map userData = storage.getItem('userData');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Authenticate(
                  id: 1,
                  data: userData,
                )));
  }

  //checks if a user has been deleted
  _checkIfDeleted() async {
    String id = FirebaseAuth.instance.currentUser.uid;
    final DatabaseReference database = FirebaseDatabase.instance.reference();
    userDeleteSubscription =
        database.child('users').onChildRemoved.listen((event) async {
      if (id == event.snapshot.key) {
        await storage.setItem('userData', {'val': 'deleted'});
        Phoenix.rebirth(context);
        await GoogleSignIn().signOut();
        await FacebookLogin().logOut();
      }
    });
  }

  //gets the current level of gas in the user's cylinder from the database
  _getGasLevel() async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    final DatabaseReference database = FirebaseDatabase.instance.reference();
    gasLevelStream = database
        .child('gas_monitor')
        .child(uid)
        .child('gas_level')
        .onValue
        .listen((event) {
      setState(() {
        var snap = event.snapshot.value;
        if (snap != null)
          value = double.parse(snap.toString()) > 100.0
              ? 100.0
              : double.parse(snap.toString()) < 0.0
                  ? 0.0
                  : double.parse(snap.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserInformation();
    _checkIfDeleted();
    _getGasLevel();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    }, onLaunch: (Map<String, dynamic> message) async {
      Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false)
          .updateCurrentIndex(1);
      print('onLaunch: $message');
    }, onResume: (Map<String, dynamic> message) async {
      Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false)
          .updateCurrentIndex(1);
      print('onResume: $message');
    });
  }

  @override
  void dispose() {
    if (userDataStream != null) userDataStream.cancel();
    if (gasLevelStream != null) gasLevelStream.cancel();
    if (userDeleteSubscription != null) userDeleteSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentBottomNavigationBarIndex =
        Provider.of<ChangeButtonNavigationBarIndex>(context).currentIndex;
    List<Widget> _bottomNavigationBarItemBody = [
      Home(showNumberNotVerified, registerUserNumber),
      Order(value),
      Profile(photoURL, snap),
    ];

    return Scaffold(
      key: _scaffoldKey,
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
        title: Text(
          _navigationBarTitle[_currentBottomNavigationBarIndex],
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: MyDrawer(photoURL: photoURL, logout: logout),
      body: _bottomNavigationBarItemBody[_currentBottomNavigationBarIndex],
      bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Color.fromRGBO(255, 255, 255, 0.5),
          selectedItemColor: Color.fromRGBO(255, 255, 255, 1),
          showUnselectedLabels: false,
          showSelectedLabels: false,
          iconSize: 25,
          currentIndex: _currentBottomNavigationBarIndex,
          backgroundColor: Theme.of(context).buttonColor,
          onTap: (index) {
            Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false)
                .updateCurrentIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _currentBottomNavigationBarIndex == 0
                        ? Color.fromRGBO(255, 255, 255, 0.5)
                        : Theme.of(context).buttonColor,
                  ),
                  child: Icon(Icons.home),
                ),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _currentBottomNavigationBarIndex == 1
                          ? Color.fromRGBO(255, 255, 255, 0.5)
                          : Theme.of(context).buttonColor,
                    ),
                    child: Icon(Icons.shopping_cart)),
                label: 'Order'),
            BottomNavigationBarItem(
                icon: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _currentBottomNavigationBarIndex == 2
                          ? Color.fromRGBO(255, 255, 255, 0.5)
                          : Theme.of(context).buttonColor,
                    ),
                    child: Icon(Icons.settings)),
                label: 'Profile')
          ]),
    );
  }
}
