import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {

  //calls the function that would display the number not verified popup for unverified users.
  // This is to ensure that the popUp receives the dashboard context and still shows even if the user has navigated away from the home page
  final Function numberNotVerified;

  //calls the function that tells new users who have not added a phone number to add one
  final Function addNumber;
  Home(this.numberNotVerified, this.addNumber);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double value; //the value that shows at the center of the gauge
  final uid = FirebaseAuth.instance.currentUser.uid;
  final DatabaseReference database = FirebaseDatabase.instance.reference();
  StreamSubscription gasLevelStream;
  StreamSubscription userPurchaseHistoryStream;
  List userPurchaseHistory = [];
  final formatCurrency =
      new NumberFormat.currency(locale: 'en_US', symbol: '#');

  //gets the current level of gas in the user's cylinder from the database
  _getGasLevel() async {
    gasLevelStream = database
        .child('gas_monitor')
        .child(uid)
        .child('gas_level')
        .onValue
        .listen((event) {
      setState(() {
        var snap = event.snapshot.value;
        value = double.parse(snap.toString());
      });
    });
  }

  //gets the purchase history of the user from the database
  _getRecentActivities() {
    var thisData = database.child('orders').child('personalOrders').child(uid);
    userPurchaseHistoryStream = thisData.onValue.listen((event) {
      if (event != null) {
        userPurchaseHistory = [];
        thisData.orderByChild('created').onChildAdded.forEach((element) {
          userPurchaseHistory.add(element.snapshot.value);
        });
      }
    });
  }

  //the functions checks if the user's phone number has been verified. if it has not been verified,
  // the verifyNumber variable is set to true and the user is asked to verify their number;
  _isUserVerified() async {
    await Future.delayed(Duration(seconds: 2));
    final snapshot = await FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uid)
        .once();
    if (snapshot.value['number'] == '') {
      widget.addNumber();
    }
    if (snapshot.value['number'] != '' &&
        snapshot.value['isNumberVerified'] == false) {
      //shows the dialog asking users whose numbers have not been verified to verify it
      widget.numberNotVerified(snapshot.value['number']);
    }
  }

  @override
  void initState() {
    super.initState();
    _isUserVerified();
    _getGasLevel();
    _getRecentActivities();
  }

  @override
  void dispose() {
    if (gasLevelStream != null) gasLevelStream.cancel();
    if (userPurchaseHistoryStream != null) userPurchaseHistoryStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext myContext) {
    double width = MediaQuery.of(myContext).size.width;
    Color color = Colors.blue;
    if (value != null) {
      color = value >= 70
          ? Colors.green[700]
          : value >= 40
              ? Colors.yellow[700]
              : value >= 21
                  ? Colors.orange[700]
                  : Colors.red[700];
    }
    return LayoutBuilder(
      builder: (context, viewportConstraint) {
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraint.maxHeight,
                maxWidth: 500,
                minWidth: 200
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      flex: 10,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(60, 80, 60, 60),
                        alignment: Alignment.bottomCenter,
                        width: width,
                        constraints: BoxConstraints(minHeight: 250),
                        child: Stack(
                          overflow: Overflow.visible,
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: width > 500 ? -500 * 0.12 : -width * 0.15,
                              child: Container(
                                height: width > 500 ? 500 * 0.12 : width * 0.15,
                                width: width * 0.5,
                                child: CustomPaint(
                                  painter: CylinderTop(
                                    color: color,
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: width > 500 ? -500 * 0.04 : -width * 0.06,
                              child: Container(
                                width: width * 0.4,
                                height: width > 500 ? 500 * 0.04 : width * 0.06,
                                decoration: BoxDecoration(
                                    border: BorderDirectional(
                                  bottom: BorderSide(color: color, width: 4),
                                  end: BorderSide(color: color, width: 4),
                                  start: BorderSide(color: color, width: 4),
                                )),
                              ),
                            ),

                            //this container specifies the height for displaying the gauge
                            Container(
                              child: Center(
                                // child: SfRadialGauge(
                                //   axes: <RadialAxis>[
                                //     RadialAxis(
                                //         minimum: 0,
                                //         maximum: 100,
                                //         showLabels: false,
                                //         showTicks: false,
                                //         startAngle: 115,
                                //         endAngle: 65,
                                //         axisLineStyle: AxisLineStyle(
                                //             thickness: 0.2,
                                //             cornerStyle: CornerStyle.bothCurve,
                                //             color: Color.fromRGBO(238, 238, 238, 1),
                                //             thicknessUnit: GaugeSizeUnit.factor),
                                //         pointers: <GaugePointer>[
                                //           //shows the progress of the gauge in terms of colors
                                //           RangePointer(
                                //               value: value,
                                //               cornerStyle: CornerStyle.bothCurve,
                                //               width: 0.2,
                                //               sizeUnit: GaugeSizeUnit.factor,
                                //               gradient: SweepGradient(colors: [
                                //                 Color.fromRGBO(148, 153, 196, 1),
                                //                 Color.fromRGBO(77, 147, 246, 1)
                                //               ]))
                                //         ],
                                //         annotations: <GaugeAnnotation>[
                                //           //shows the text at the center of the gauge
                                //           GaugeAnnotation(
                                //               positionFactor: 0.1,
                                //               angle: 90,
                                //               widget: Text(
                                //                 '${value.round()}%',
                                //                 style: TextStyle(
                                //                     fontSize: 36, color: Colors.black),
                                //               ))
                                //         ]),
                                //   ],
                                // ),
                                child: LiquidLinearProgressIndicator(
                                  direction: Axis.vertical,
                                  borderRadius: 30,
                                  borderWidth: 4,
                                  value: value == null ? 0 : value / 100,
                                  backgroundColor: Colors.transparent,
                                  center: Text(
                                    value == null
                                        ? 'loading...'
                                        : '${value.round()}%',
                                    style: TextStyle(
                                        fontSize: value == null ? 25 : 50,
                                        color: Colors.black),
                                  ),
                                  borderColor: color,
                                  valueColor: value == null
                                      ? AlwaysStoppedAnimation(Colors.blue)
                                      : value >= 70
                                          ? AlwaysStoppedAnimation(Colors.green)
                                          : value >= 40
                                              ? AlwaysStoppedAnimation(
                                                  Colors.yellow)
                                              : value >= 21
                                                  ? AlwaysStoppedAnimation(
                                                      Colors.orange)
                                                  : AlwaysStoppedAnimation(
                                                      Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (value != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: value > 20 ? Colors.black : Colors.red),
                              children: [
                                TextSpan(text: 'Dear Customer, you have '),
                                TextSpan(
                                    text: '${value.toInt()}%',
                                    style: TextStyle(fontSize: 24)),
                                TextSpan(text: ' of your gas remaining')
                              ]),
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(left: 30.0, bottom: 10),
                    //   child: Text(
                    //     'Recent Activities',
                    //     style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    //   ),
                    // ),
                    // userPurchaseHistory != null && userPurchaseHistory.isNotEmpty
                    //     ? ListView.builder(
                    //         itemCount: userPurchaseHistory.length,
                    //         shrinkWrap: true,
                    //         physics: ClampingScrollPhysics(),
                    //         reverse: true,
                    //         itemBuilder: (context, index) {
                    //           return Container(
                    //             color: index % 2 == 0
                    //                 ? Color.fromRGBO(244, 246, 248, 1)
                    //                 : Color.fromRGBO(255, 255, 255, 1),
                    //             child: Padding(
                    //               padding: const EdgeInsets.only(left: 14.0),
                    //               child: ListTile(
                    //                 leading: Padding(
                    //                   padding: EdgeInsets.only(top: 8),
                    //                   child: Icon(FontAwesomeIcons.gasPump),
                    //                 ),
                    //                 title: Text(
                    //                   'Small Cylinder',
                    //                   style: TextStyle(
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.w500,
                    //                       color: Color.fromRGBO(179, 179, 182, 1)),
                    //                 ),
                    //                 subtitle: Text(
                    //                     '${userPurchaseHistory[index]['size']} x ${userPurchaseHistory[index]['quantity']} Qty',
                    //                     style: TextStyle(
                    //                         fontSize: 16,
                    //                         fontWeight: FontWeight.w500,
                    //                         color: Color.fromRGBO(179, 179, 182, 1))),
                    //                 trailing: Text(
                    //                   '${formatCurrency.format(userPurchaseHistory[index]['price'] / 100)}',
                    //                   style: TextStyle(
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.w500,
                    //                       color: Color.fromRGBO(179, 179, 182, 1)),
                    //                 ),
                    //               ),
                    //             ),
                    //           );
                    //         })
                    //     : Container(
                    //         alignment: Alignment.center,
                    //         padding: EdgeInsets.only(top: 20, bottom: 50),
                    //         child: Text(
                    //           'No recent activity',
                    //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    //         )),
                    Spacer(),
                    if (value != null && value <= 20)
                      Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 30, 34),
                        child: InkWell(
                          onTap: () {
                            Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false).updateCurrentIndex(1);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                              color: Theme.of(context).buttonColor,

                            child: Text(
                              'Quick Order',
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CylinderTop extends CustomPainter {
  final Color color;
  CylinderTop({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.2);

    path.quadraticBezierTo(
        0, size.height * 0.375, size.width * 0.35, size.height * 0.50);
    path.lineTo(size.width * 0.35, size.height);

    path.moveTo(size.width * 0.65, size.height);
    path.lineTo(size.width * 0.65, size.height * 0.5);
    path.quadraticBezierTo(
        size.width, size.height * 0.375, size.width * 0.8, size.height * 0.2);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0, size.width * 0.2, size.height * 0.2);
    path.moveTo(size.width * 0.13, size.height * 0.34);
    path.lineTo(size.width * 0.13, size.height);
    path.moveTo(size.width * 0.87, size.height * 0.34);
    path.lineTo(size.width * 0.87, size.height);
    path.moveTo(size.width * 0.35, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
        size.width * 0.65, size.height * 0.7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
