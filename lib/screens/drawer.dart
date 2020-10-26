import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiakia/screens/profile.dart';
import 'package:localstorage/localstorage.dart';

class MyDrawer extends StatelessWidget {
  final Map userData;
  final bool keepDrawerOpen;  //this value is used to decide if a vertical divider should be between the drawer and the dashboard or not
  MyDrawer({this.userData, this.keepDrawerOpen});
  final storage = new LocalStorage('user_data.json');


  //retrieves the stored data from the user's local storage
  getUserDataFromStorage() {
    return storage.getItem('userData');
  }

  @override
  Widget build(BuildContext context) {
    String name, number, email, verificationStatus;
    Map<String, dynamic> data = getUserDataFromStorage();
    if (data != null) {
      name = data['name'];
      number = data['number'];
      if (data['status'] == true)
        verificationStatus = 'Verified';
      else
        verificationStatus = 'Not Verified';
      email = data['email'];
    }

    return Drawer(
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                    height: 190,
                    child: data == null
                        ? Container(
                            color: Color.fromRGBO(77, 172, 246, 1),
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Profile()));
                            },
                            child: DrawerHeader(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(77, 172, 246, 1)),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      child: Text(
                                        name[0],
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
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
                                    Text(
                                      email,
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Number: 0${number.substring(4, 14)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color:
                                                Color.fromRGBO(10, 10, 10, 0.7),
                                          ),
                                        ),
                                        Text(
                                          'Status: $verificationStatus',
                                          style: TextStyle(
                                            fontSize: 13,
                                              color: Color.fromRGBO(
                                                  225, 220, 190, 0.8)),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                  ),
                ],
              ),
            ),
            if (keepDrawerOpen)
              VerticalDivider(
                width: 2,
                color: Colors.grey[300],
                thickness: 2,
              ),
          ],
        ),
      ),
    );
  }
}
