import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kiakia/screens/order_screen/order_received.dart';
import 'package:kiakia/screens/order_screen/track_rider.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String phoneNumber = '+2348117933576';

  //responsible for launching the phone call app from within this app
  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    //gets the current width of the device from mediaQuery
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
          )
        ],
        backgroundColor: Color(0xffffffff),
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      endDrawer: Drawer(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 15, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(0, 0, 0, 1)),
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 142, 27, 1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text(
                      'Ongoing',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  color: index % 2 == 0
                      ? Color.fromRGBO(244, 246, 248, 1)
                      : Color.fromRGBO(255, 255, 255, 1),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Icon(FontAwesomeIcons.gasPump),
                      ),
                      title: Text(
                        'Small Cylinder',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(179, 179, 182, 1)),
                      ),
                      subtitle: Text('3kg X 1 Qty',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(179, 179, 182, 1))),
                      trailing: Text(
                        '#900',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(179, 179, 182, 1)),
                      ),
                    ),
                  ),
                );
              }),
          Padding(
            padding: EdgeInsets.only(top: 30, left: 30, bottom: 5),
            child: Text(
              'Rider',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            color: Color.fromRGBO(244, 246, 248, 1),
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 30),
              leading: CircleAvatar(
                backgroundImage: ExactAssetImage('assets/niza.jpg'),
              ),
              title: Text(
                'Undie Ebenezer',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18),
              ),
              subtitle: Text(
                phoneNumber,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(179, 179, 182, 1)),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  launchURL('tel: $phoneNumber');
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: width / 2 - 5,
                  color: Color.fromRGBO(77, 172, 245, 1),
                  child: Text(
                    'Call',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TrackRider()));
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: width / 2 - 5,
                  color: Color.fromRGBO(77, 172, 245, 1),
                  child: Text(
                    'Track',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: width,
              height: 50,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Color.fromRGBO(77, 172, 246, 1), width: 2)),
              child: Text(
                'Cancel Order',
                style: TextStyle(
                    color: Color.fromRGBO(77, 172, 246, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => OrderReceived()));
            },
            child: Container(
              width: width,
              height: 50,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromRGBO(77, 172, 246, 1)),
              child: Text(
                'Pay Now',
                style: TextStyle(
                    color: Color.fromRGBO(246, 248, 250, 1),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // this container displays the login button and is wrapped with InkWell to make it clickable
        ],
      ),
    );
  }
}
