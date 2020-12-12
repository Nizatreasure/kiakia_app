import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kiakia/drawer/about.dart';
import 'package:kiakia/drawer/faq.dart';
import 'package:kiakia/drawer/transaction_history.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  final String photoURL;
  final Function logout;
  MyDrawer({this.photoURL, this.logout});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final storage = new LocalStorage('user_data.json');
  String name;
  Map<String, dynamic> user;

  //the function that gets the user data from the local storage
  _getUserDataFromStorage() async {
    await storage.ready;
    user = await storage.getItem('userData');
    if (user != null) {
      name = user['name'];
      setState(() {});
    }
  }

  @override
  void initState() {
    _getUserDataFromStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List initials = [];
    if (user != null) {
      for (int i = 0; i < name.split(' ').length; i++) {
        if (name.split(' ')[i] != '' && initials.length < 2)
          initials.add(name.split(' ')[i][0]);
      }
    }
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Color.fromRGBO(77, 172, 246, 1),
            padding: EdgeInsets.all(10),
            child: user == null
                ? Container(
                    height: 150,
                    color: Color.fromRGBO(77, 172, 246, 1),
                  )
                : Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            widget.photoURL == null || widget.photoURL == ''
                                ? Colors.white
                                : Color.fromRGBO(77, 172, 246, 1),
                        child: widget.photoURL == null || widget.photoURL == ''
                            ? Center(
                                child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black),
                                      children: [
                                        TextSpan(
                                            text:
                                                '${initials[0].toUpperCase()}'),
                                        if (initials.length > 1)
                                          TextSpan(
                                              text:
                                                  '${initials[1].toUpperCase()}')
                                      ]),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: widget.photoURL,
                                  placeholder: (context, url) => CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.white,
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                          radius: 50,
                                          child: Icon(
                                            Icons.person,
                                            size: 55,
                                          )),
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 23,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Provider.of<ChangeButtonNavigationBarIndex>(context,
                                  listen: false)
                              .updateCurrentIndex(2);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  width: 2)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'view profile',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  ),
          ),
          SizedBox(height: 30),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionHistory()));
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 10, 5, 10),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.history,
                    size: 19,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withOpacity(0.75),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Transaction History',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .color
                          .withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => FAQ()));
            },
            splashColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 10, 5, 10),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.question,
                    size: 19,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withOpacity(0.75),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'FAQ',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .color
                          .withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => About()));
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 10, 5, 10),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.addressBook,
                    size: 19,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withOpacity(0.75),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'About',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .color
                          .withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              contactUs(context);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 10, 5, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.call,
                    size: 19,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withOpacity(0.75),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .color
                          .withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              showLogOutConfirmation();
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 10, 5, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 19,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withOpacity(0.75),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .color
                          .withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  void showLogOutConfirmation() {
    showDialog(
        context: context,
        barrierDismissible: false,
        child: Builder(builder: (context) {
          return AlertDialog(
            content: Text('Sure you want to log out?', style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w500),),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('NO', style: TextStyle(fontSize: 22),),
              ),
              FlatButton(
                onPressed: () async {
                  Provider.of<ChangeButtonNavigationBarIndex>(context,
                          listen: false)
                      .updateCurrentIndex(0);
                  Provider.of<ChangeButtonNavigationBarIndex>(context,
                          listen: false)
                      .updatePrices({});
                  Navigator.pop(context);
                  await Future.delayed(Duration(seconds: 1));
                  await AuthenticationService().logOut();
                  await widget.logout();
                },
                child: Text('YES', style: TextStyle(fontSize: 22),),
              ),
            ],
          );
        }));
  }
}

Future contactUs(context) async {
  void launchWhatsApp(
      {@required String number,
      @required String message,
      @required BuildContext myContext}) async {
    String url = "whatsapp://send?phone=$number&text=${Uri.parse(message)}";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showErrorDialog(
          'Could not launch WhatsApp or WhatsApp isn\'t installed', myContext);
    }
  }

  void launchPhoneCall(url, BuildContext myContext) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showErrorDialog('Could not launch app', myContext);
    }
  }

  String tel = '+2348140005500';
  showDialog(
    context: context,
    child: Builder(builder: (context) {
      return Dialog(
        child: Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  launchPhoneCall('tel: $tel', context);
                },
                splashColor: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.call,
                      color: Colors.blue,
                      size: 32,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Call',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  launchWhatsApp(
                      number: tel,
                      message: 'This is a test message',
                      myContext: context);
                },
                splashColor: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat,
                      color: Colors.blue,
                      size: 32,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Chat',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

Future showErrorDialog(String message, BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    child: Builder(builder: (context) {
      return AlertDialog(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          )
        ],
      );
    }),
  );
}
