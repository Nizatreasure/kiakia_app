import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 26, color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(77, 172, 246, 1),
        centerTitle: true,
      ),
      body: Column(
        children: [

        ],
      ),
    );
  }
}
