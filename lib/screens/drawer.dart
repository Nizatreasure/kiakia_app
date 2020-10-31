import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiakia/screens/profile.dart';
import 'package:localstorage/localstorage.dart';

class MyDrawer extends StatefulWidget {
  final String photoURL;
  MyDrawer({this.photoURL});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final storage = new LocalStorage('user_data.json');
  String name, number, email, verificationStatus;
  Map<String, dynamic> user;

  //the function that gets the user data from the local storage
  _getUserDataFromStorage() async {
    await storage.ready;
    user = await storage.getItem('userData');
    if (user != null) {
      name = user['name'];
      number = user['number'];
      if (user['status'] == true)
        verificationStatus = 'Verified';
      else
        verificationStatus = 'Not Verified';
      email = user['email'];
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
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Color.fromRGBO(77, 172, 246, 1),
            padding: EdgeInsets.all(10),
            child: user == null
                ? Container(
                    color: Color.fromRGBO(77, 172, 246, 1),
                  )
                : InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile()));
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                            radius: 30,
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    name[0],
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                widget.photoURL == null ||
                                        widget.photoURL == ''
                                    ? Container(
                                        height: 0,
                                        width: 0,
                                      )
                                    : Center(
                                        child: ClipOval(
                                            child: Image.network(
                                          widget.photoURL,
                                          fit: BoxFit.cover,
                                        )),
                                      )
                              ],
                            )),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          name,
                          style: TextStyle(
                              fontSize: 23,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          email,
                          style: TextStyle(
                              color: Colors.black54, fontSize: 15),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          number == ''
                              ? 'No number for account. Please add your number'
                              : 'Number: 0${number.substring(4, 14)}',
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: number == ''
                                ? Colors.red[400]
                                : Color.fromRGBO(10, 10, 10, 0.7),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (verificationStatus == 'Not Verified' && number != '') Text(
                           'Status: $verificationStatus',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.red),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
