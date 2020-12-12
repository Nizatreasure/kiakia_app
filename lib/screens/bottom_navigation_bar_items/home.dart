import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:kiakia/screens/order_screen/detailed_transaction_history.dart';
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
  List orderDetails = [];
  List orderPackages = [];
  String name, lastUpdated, lastRefill;
  final formatCurrency =
      new NumberFormat.currency(locale: 'en_US', symbol: '\u{20A6}');

  //gets the current level of gas in the user's cylinder from the database
  _getGasLevel() async {
    gasLevelStream =
        database.child('gas_monitor').child(uid).onValue.listen((event) {
      setState(() {
        var snap = event.snapshot.value;
        value = double.parse(snap['gas_level'].toString()) > 100.0
            ? 100.0
            : double.parse(snap['gas_level'].toString()) < 0.0
                ? 0.0
                : double.parse(snap['gas_level'].toString());
        if (snap['lastUpdated'] != null)
          lastUpdated = snap['lastUpdated'].toString();
        if (snap['lastRefill'] != null)
          lastRefill = snap['lastRefill'].toString();
      });
    });
  }

  //gets the purchase history of the user from the database
  _getRecentActivities() {
    var thisData = database.child('orders').child('userOrders').child(uid);
    userPurchaseHistoryStream = thisData.onValue.listen((event) {
      if (event != null) {
        userPurchaseHistory = [];
        orderDetails = [];
        orderPackages = [];
        thisData.orderByChild('created').onChildAdded.forEach((element) {
          int currentDateTime = DateTime.now().millisecondsSinceEpoch;
          if (currentDateTime - int.parse(element.snapshot.value['created']) <
              259200000) {

                userPurchaseHistory.add(element.snapshot.value);
                orderDetails
                    .add(element.snapshot.value['order'].values.toList());
                orderPackages
                    .add(element.snapshot.value['order'].keys.toList());
                if (mounted)
                  setState(() {});
          }
        });
      }
    });
  }

  //the functions checks if the user's phone number has been verified. if it has not been verified,
  // the verifyNumber variable is set to true and the user is asked to verify their number;
  _isUserVerified() async {
    final snapshot = await database.child('users').child(uid).once();
    if (mounted)
      setState(() {
        name = snapshot.value['name'].toString().split(' ')[0];
      });
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
    double height = MediaQuery.of(myContext).size.height;
    Color color = Colors.blue[900];
    return (userPurchaseHistory != null && userPurchaseHistory.isNotEmpty) ||
            height < 650 ||
            width < 380
        ? smallCylinder()
        : LayoutBuilder(
            builder: (context, viewportConstraint) {
              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraint.maxHeight,
                        maxWidth: 500,
                        minWidth: 200),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          if (lastRefill != null && lastRefill.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Last Refill: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastUpdated)))}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w900),
                                  )),
                            ),
                          Expanded(
                            flex: 10,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(60, 80, 60, 60),
                              alignment: Alignment.bottomCenter,
                              width: width,
                              constraints: BoxConstraints(minHeight: 350),
                              child: Stack(
                                overflow: Overflow.visible,
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    top: width > 500
                                        ? -500 * 0.12
                                        : -width * 0.15,
                                    child: Container(
                                      height: width > 500
                                          ? 500 * 0.12
                                          : width * 0.15,
                                      width: width * 0.5,
                                      child: CustomPaint(
                                        painter: CylinderTop(
                                            color: color,
                                            value: width > 500 ? 1.23 : 1.1),
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    bottom: width > 500
                                        ? -500 * 0.03
                                        : -width * 0.04,
                                    child: Container(
                                      width: width > 500
                                          ? 500 * 0.45
                                          : width * 0.4,
                                      height: width > 500
                                          ? 500 * 0.03
                                          : width * 0.06,
                                      decoration: BoxDecoration(
                                          border: BorderDirectional(
                                        bottom:
                                            BorderSide(color: color, width: 6),
                                        end: BorderSide(color: color, width: 6),
                                        start:
                                            BorderSide(color: color, width: 6),
                                      )),
                                    ),
                                  ),

                                  //this container specifies the height for displaying the gauge
                                  Container(
                                    child: Center(
                                      child: LiquidLinearProgressIndicator(
                                        direction: Axis.vertical,
                                        borderRadius: 90,
                                        borderWidth: 6,
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
                                            ? AlwaysStoppedAnimation(
                                                Colors.blue)
                                            : value >= 70
                                                ? AlwaysStoppedAnimation(
                                                    Colors.green)
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
                          if (value != null && name != null && name.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: value > 20
                                            ? Colors.black
                                            : Colors.red),
                                    children: [
                                      TextSpan(text: 'Dear $name, you have '),
                                      TextSpan(
                                          text: '${value.toInt()}%',
                                          style: TextStyle(fontSize: 24)),
                                      TextSpan(text: ' of your gas remaining')
                                    ]),
                              ),
                            ),
                          if (lastUpdated != null && lastUpdated.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 15, 20, 0),
                              child: Text(
                                'Last Updated at ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastUpdated)))}   ${DateFormat.jms().format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastUpdated)))}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          if (value != null && value <= 20)
                            Padding(
                              padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                              child: InkWell(
                                onTap: () {
                                  Provider.of<ChangeButtonNavigationBarIndex>(
                                          context,
                                          listen: false)
                                      .updateCurrentIndex(1);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  color: Theme.of(context).buttonColor,
                                  child: Text(
                                    'Schedule Refill',
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

  //the gas cylinder display when there is a recent activity
  Widget smallCylinder() {
    Color color = Colors.blue[900];
    return ListView(
      children: [
        if (lastRefill != null && lastRefill.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Last Refill: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastUpdated)))}',
                  style: TextStyle(fontWeight: FontWeight.w900),
                )),
          ),
        Container(
          height: 250,
          margin: EdgeInsets.fromLTRB(60, 50, 60, 30),
          alignment: Alignment.bottomCenter,
          child: Stack(
            overflow: Overflow.visible,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -25,
                child: Container(
                  height: 25,
                  width: 150,
                  child: CustomPaint(
                    painter: CylinderTop(color: color, value: 1.3),
                  ),
                ),
              ),

              Positioned(
                bottom: -8,
                child: Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.blue[900],
                      border: BorderDirectional(
                        bottom: BorderSide(color: color, width: 8),
                        end: BorderSide(color: color, width: 8),
                        start: BorderSide(color: color, width: 8),
                      )),
                ),
              ),

              //this container specifies the height for displaying the gauge
              Container(
                width: 190,
                child: Center(
                  child: LiquidLinearProgressIndicator(
                    direction: Axis.vertical,
                    borderRadius: 60,
                    borderWidth: 6,
                    value: value == null ? 0 : value / 100,
                    backgroundColor: Colors.transparent,
                    center: Text(
                      value == null ? 'loading...' : '${value.round()}%',
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
                                ? AlwaysStoppedAnimation(Colors.yellow)
                                : value >= 21
                                    ? AlwaysStoppedAnimation(Colors.orange)
                                    : AlwaysStoppedAnimation(Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (value != null && name != null && name.isNotEmpty)
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
                    TextSpan(text: 'Dear $name, you have '),
                    TextSpan(
                        text: '${value.toInt()}%',
                        style: TextStyle(fontSize: 24)),
                    TextSpan(text: ' of your gas remaining')
                  ]),
            ),
          ),
        if (lastUpdated != null && lastUpdated.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 15, 20, 0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Last Updated at ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastUpdated)))}   ${DateFormat.jms().format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastUpdated)))}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        SizedBox(
          height: 20,
        ),
        if (value != null && value <= 20)
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 34),
            child: InkWell(
              onTap: () {
                Provider.of<ChangeButtonNavigationBarIndex>(context,
                        listen: false)
                    .updateCurrentIndex(1);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                color: Theme.of(context).buttonColor,
                child: Text(
                  'Schedule Refill',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
          ),
        if (userPurchaseHistory != null && userPurchaseHistory.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 30.0, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Activities',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
          ),
        ListView.builder(
            itemCount: userPurchaseHistory.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            reverse: true,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailedTransactionHistory(
                                general: userPurchaseHistory[index],
                                order: orderDetails[index],
                                package: orderPackages[index],
                              )));
                },
                child: Container(
                  color: index % 2 == 0
                      ? Color.fromRGBO(244, 246, 248, 1)
                      : Color.fromRGBO(255, 255, 255, 1),
                  padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        child: Text(orderDetails[index][0]['quantity'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 22)),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'x',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .color
                                          .withOpacity(0.75),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17),
                                  children: [
                                    TextSpan(text: orderPackages[index][0]),
                                    if (orderPackages[index].length > 1)
                                      TextSpan(
                                          text:
                                              ' +${orderPackages[index].length - 1}')
                                  ]),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(orderDetails[index][0]['size'],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .color
                                        .withOpacity(0.75),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                              formatCurrency.format(double.parse(
                                  userPurchaseHistory[index]['total'])),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .buttonColor
                                      .withOpacity(0.75),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 10),
                          Text(
                            DateFormat.yMd().format(
                                DateTime.fromMillisecondsSinceEpoch(int.parse(
                                    userPurchaseHistory[index]['created']))),
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromRGBO(179, 179, 182, 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            })
      ],
    );
  }
}

class CylinderTop extends CustomPainter {
  final Color color;
  final double value;
  CylinderTop({@required this.color, @required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 6
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
    path.lineTo(size.width * 0.13, size.height * value);
    path.moveTo(size.width * 0.87, size.height * 0.34);
    path.lineTo(size.width * 0.87, size.height * value);
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
