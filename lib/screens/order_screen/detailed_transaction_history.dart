import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiakia/screens/order_screen/track_rider.dart';
import 'package:localstorage/localstorage.dart';

class DetailedTransactionHistory extends StatefulWidget {
  final List package, order;
  final Map general;
  DetailedTransactionHistory({this.general, this.order, this.package});
  @override
  _DetailedTransactionHistoryState createState() =>
      _DetailedTransactionHistoryState();
}

class _DetailedTransactionHistoryState
    extends State<DetailedTransactionHistory> {
  final formatCurrency =
      new NumberFormat.currency(locale: 'en_US', symbol: '\u{20A6} ');
  StreamSubscription trackingInformation;
  Map riderLocation;
  final storage = new LocalStorage('user_data.json');

  _isTrackingAvailable() async {
    trackingInformation = FirebaseDatabase.instance
        .reference()
        .child('Transactions')
        .child(FirebaseAuth.instance.currentUser.uid)
        .child(widget.general['transactionID'])
        .onValue
        .listen((event) {
      setState(() {
        riderLocation = event.snapshot.value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _isTrackingAvailable();
  }

  @override
  void dispose() {
    trackingInformation.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        centerTitle: true,
        elevation: 0,
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
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Align(
                alignment: Alignment(-1, 0),
                child: RichText(
                  text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 14),
                      children: [
                        TextSpan(
                            text: 'Status: ',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(
                            text: widget.general['status'].toString(),
                            style: TextStyle(
                                color: Color.fromRGBO(255, 142, 27, 1))),
                      ]),
                ),
              ),
            ),
            if (widget.general['reference'] != null &&
                widget.general['reference'] != '')
              Padding(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: RichText(
                  text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 14),
                      children: [
                        TextSpan(
                            text: 'Reference: ',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(
                            text: widget.general['reference'].toString(),
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                ),
              ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: widget.package.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Color.fromRGBO(244, 246, 248, 1),
                  padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
                  margin: EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        child: Text(widget.order[index]['quantity'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 22)),
                      ),
                      SizedBox(width: 10),
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
                          children: [
                            Text(widget.package[index],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .color
                                        .withOpacity(0.75),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17)),
                            SizedBox(
                              height: 5,
                            ),
                            Text(widget.order[index]['size'],
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
                      Text(
                          formatCurrency.format(
                              double.parse(widget.order[index]['amount'])),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .buttonColor
                                  .withOpacity(0.75),
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 15, 10),
              child: Row(
                children: [
                  Text(
                    'Order',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.5),
                        fontSize: 17),
                  ),
                  Spacer(),
                  Text(
                    formatCurrency.format(
                        double.parse(widget.general['total']) -
                            double.parse(widget.general['deliveryCharge'])),
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.5)),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 15, 20),
              child: Row(
                children: [
                  Text(
                    'Delivery Charge',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.5),
                        fontSize: 17),
                  ),
                  Spacer(),
                  Text(
                    formatCurrency
                        .format(double.parse(widget.general['deliveryCharge'])),
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.5)),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 15, 20),
              child: Row(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.5),
                        fontSize: 19,
                        fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  Text(
                    formatCurrency
                        .format(double.parse(widget.general['total'])),
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.5),
                        fontSize: 19,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
              child: Text(
                'Address',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                      color: Color.fromRGBO(57, 138, 239, 0.05), width: 3)),
              padding: EdgeInsets.fromLTRB(15, 7, 10, 7),
              child: Text(
                widget.general['location']['address'],
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .color
                      .withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
              child: Text(
                'Payment Mode',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                      color: Color.fromRGBO(57, 138, 239, 0.05), width: 3)),
              padding: EdgeInsets.fromLTRB(15, 7, 10, 7),
              child: Text(
                widget.general['paymentMethod'],
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .color
                      .withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
              child: Text(
                'Date',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                      color: Color.fromRGBO(57, 138, 239, 0.05), width: 3)),
              padding: EdgeInsets.fromLTRB(15, 7, 10, 7),
              child: Text(
                '${DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.general['created'])))}    ${DateFormat.jms().format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.general['created'])))}',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .color
                      .withOpacity(0.5),
                ),
              ),
            ),
            if (widget.general['schedule'] != null &&
                widget.general['schedule'] != '')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                    child: Text(
                      'Scheduled Date',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: Color.fromRGBO(57, 138, 239, 0.05),
                            width: 3)),
                    padding: EdgeInsets.fromLTRB(15, 7, 10, 7),
                    child: Text(
                      widget.general['schedule'],
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              child: FlatButton(
                onPressed: riderLocation == null
                    ? null
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TrackRider(
                                      rider: riderLocation,
                                      userLocation: widget.general['location'],
                                      transactionID:
                                          widget.general['transactionID'],
                                    )));
                      },
                color: Theme.of(context).buttonColor,
                disabledColor: Theme.of(context).buttonColor.withOpacity(0.25),
                height: 50,
                child: Text('Track',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
