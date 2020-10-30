import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';

class Home extends StatefulWidget {
  //receives the function for switching from home to order page when a user clicks on quick order
  final Function switchToOrderPage;

  //calls the function that would display the number not verified popup for unverified users.
  // This is to ensure that the popUp receives the dashboard context and still shows even if the user has navigated away from the home page
  final Function numberNotVerified;

  //calls the function that tells new users who have not added a phone number to add one
  final Function addNumber;
  Home(this.switchToOrderPage, this.numberNotVerified, this.addNumber);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double value = 78; //the value that shows at the center of the gauge

  //the functions checks if the user's phone number has been verified. if it has not been verified,
  // the verifyNumber variable is set to true and the user is asked to verify their number;
  _isUserVerified() async {
        final uid = FirebaseAuth.instance.currentUser.uid;
        await Future.delayed(Duration(seconds: 5));
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
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            //this container specifies the height for displaying the gauge
            Container(
              height: 170,
              padding: EdgeInsets.only(bottom: 15),
              child: Center(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        showLabels: false,
                        showTicks: false,
                        startAngle: 115,
                        endAngle: 65,
                        axisLineStyle: AxisLineStyle(
                            thickness: 0.2,
                            cornerStyle: CornerStyle.bothCurve,
                            color: Color.fromRGBO(238, 238, 238, 1),
                            thicknessUnit: GaugeSizeUnit.factor),
                        pointers: <GaugePointer>[
                          //shows the progress of the gauge in terms of colors
                          RangePointer(
                              value: value,
                              cornerStyle: CornerStyle.bothCurve,
                              width: 0.2,
                              sizeUnit: GaugeSizeUnit.factor,
                              gradient: SweepGradient(colors: [
                                Color.fromRGBO(148, 153, 196, 1),
                                Color.fromRGBO(77, 147, 246, 1)
                              ]))
                        ],
                        annotations: <GaugeAnnotation>[
                          //shows the text at the center of the gauge
                          GaugeAnnotation(
                              positionFactor: 0.1,
                              angle: 90,
                              widget: Text(
                                '${value.round()}%',
                                style: TextStyle(
                                    fontSize: 36, color: Colors.black),
                              ))
                        ]),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                'Gas Usage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(50, 30, 30, 34),
          child: InkWell(
            onTap: () {
              widget.switchToOrderPage();
            },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).primaryColor),
              child: Text(
                'Quick Order',
                style: TextStyle(
                    color: Color.fromRGBO(246, 248, 250, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, bottom: 10),
          child: Text(
            'Recent Activities',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: 20,
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
      ],
    );
  }
}
