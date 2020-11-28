import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:kiakia/screens/about.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:kiakia/screens/transaction_history.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  final String photoURL;
  MyDrawer({this.photoURL});

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

  void launchWhatsApp(
      {@required String number, @required String message}) async {
    String url = "whatsapp://send?phone=$number&text=${Uri.parse(message)}";

    if (await canLaunch(url)) {
      await launch(url);
    } else {}
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
                                          child: Icon(Icons.person, size: 55,)),
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
            onTap: () {
              launchWhatsApp(
                  number: "+2349082377152", message: "My name is Niza");
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
            onTap: () async {
              await AuthenticationService().logOut();
              Provider.of<ChangeButtonNavigationBarIndex>(context,
                      listen: false)
                  .updateCurrentIndex(0);
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
}
