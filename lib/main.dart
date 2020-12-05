import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:kiakia/app_theme.dart';
import 'package:kiakia/login_signup/authenticate.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:kiakia/screens/dashboard.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(Phoenix(child: MyApp()));
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
  void dispose() {
    super.dispose();
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
          padding: EdgeInsets.symmetric(horizontal: 90),
          child: Center(
            child: Image.asset('assets/gas_logo.jpg'),
          ));
    }

    // if (FirebaseAuth.instance.currentUser != null)
    //   FirebaseAuth.instance.signOut();
    //returns the application when flutterFire has been successfully initialized
    return MultiProvider(
      providers: [
        //this makes the user stream value available across all pages in the application
        StreamProvider<User>.value(
          value: AuthenticationService().user,
        ),
        ChangeNotifierProvider<ChangeButtonNavigationBarIndex>(
          create: (context) => ChangeButtonNavigationBarIndex(),
        ),
      ],

      //wraps the entire application to ensure that all textfields
      //lose focus when the user taps on any non-clickable element
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
          debugShowCheckedModeBanner: false,
          home: Consumer<ChangeButtonNavigationBarIndex>(
              builder: (context, appState, child) {
                return child;
              },
              child: Wrapper()),
          theme: lightTheme,
        ),
      ),
    );
  }
}

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final storage = new LocalStorage('user_data.json');
  Map userData = {};
  FlutterLocalNotificationsPlugin flutterNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeLocalNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterNotifications.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    await _createNotificationChannel();
  }

  Future selectNotification(String payload) async {
    print('payload: $payload');
  }

  Future<void> _createNotificationChannel() async {
    var androidNotificationChannel = AndroidNotificationChannel(
      'kiakia_notification',
      'Gas Alert',
      'Information about gas orders, gas level and promos',
      playSound: true,
      enableLights: true,
      enableVibration: true,

    );
    await flutterNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  //query the local storage to find out if the user has stored data
  //if data is stored, the user is taken directly to the login page
  _checkUserData() async {
    await storage.ready;
    userData = await storage.getItem('userData');
    if (mounted) setState(() {});
  }

  setDatabasePersistence() async {
    FirebaseDatabase database;
    database = FirebaseDatabase.instance;
    await database.setPersistenceEnabled(true);
    await database.setPersistenceCacheSizeBytes(100000000);
  }

  @override
  void initState() {
    initializeLocalNotifications();
    setDatabasePersistence();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _checkUserData();
    //decides whether to show the home or sign in page depending
    // on the information it receives from the user stream
    if (Provider.of<User>(context) == null &&
        FirebaseAuth.instance.currentUser == null) {
      if (userData == null)
        return Authenticate();
      else if (userData.isEmpty) {
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 90),
          child: Center(
            child: Image.asset('assets/gas_logo.jpg'),
          ),
        );
      }
      else if (userData['val'] == 'deleted') {
        return Authenticate(
          id: 2,
        );
      }
      else
        return Authenticate(
          id: 1,
          data: userData,
        );
    } else if (Provider.of<User>(context) != null &&
        FirebaseAuth.instance.currentUser != null) {
      return Dashboard();
    } else {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 90),
        child: Center(
          child: Image.asset('assets/gas_logo.jpg', ),
        ),
      );
    }
  }
}
