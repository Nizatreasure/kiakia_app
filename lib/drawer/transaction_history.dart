import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiakia/screens/order_screen/detailed_transaction_history.dart';

class TransactionHistory extends StatefulWidget {
  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  StreamSubscription userPurchaseHistoryStream;
  List userPurchaseHistory = [];
  List orderDetails = [];
  List orderPackages = [];
  final formatCurrency =
      new NumberFormat.currency(locale: 'en_US', symbol: '\u{20A6}');

  //gets the purchase history of the user from the database
  _getRecentActivities() {
    var thisData = FirebaseDatabase.instance
        .reference()
        .child('orders')
        .child('userOrders')
        .child(FirebaseAuth.instance.currentUser.uid);
    userPurchaseHistoryStream = thisData.onValue.listen((event) {
      if (event.snapshot.value == null)
        setState(() {
          userPurchaseHistory = null;
        });
      if (event.snapshot.value != null) {
        userPurchaseHistory = [];
        orderDetails = [];
        orderPackages = [];
        thisData.orderByChild('created').onChildAdded.forEach((element) {
          userPurchaseHistory.add(element.snapshot.value);
          orderDetails.add(element.snapshot.value['order'].values.toList());
          orderPackages.add(element.snapshot.value['order'].keys.toList());
          if(mounted) setState(() {});
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getRecentActivities();
  }

  @override
  void dispose() {
    if (userPurchaseHistoryStream != null) userPurchaseHistoryStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Transaction History'),
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
        body: userPurchaseHistory == null
            ? Center(
                child: Text(
                  'No purchase history',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : userPurchaseHistory.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: ListView.builder(
                        itemCount: userPurchaseHistory.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailedTransactionHistory(
                                            general: userPurchaseHistory[
                                                orderPackages.length -
                                                    index -
                                                    1],
                                            order: orderDetails[
                                                orderPackages.length -
                                                    index -
                                                    1],
                                            package: orderPackages[
                                                orderPackages.length -
                                                    index -
                                                    1],
                                          )));
                            },
                            child: Container(
                              height: 70,
                              color: index % 2 == 0
                                  ? Color.fromRGBO(244, 246, 248, 1)
                                  : Color.fromRGBO(255, 255, 255, 1),
                              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Container(
                                      color: index % 2 == 0
                                          ? Color.fromRGBO(255, 255, 255, 1)
                                          : Color.fromRGBO(244, 246, 248, 1),
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                          orderDetails[orderPackages.length -
                                              index -
                                              1][0]['quantity'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 22)),
                                    ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                TextSpan(
                                                    text: orderPackages[
                                                        orderPackages.length -
                                                            index -
                                                            1][0]),
                                                if (orderPackages[orderPackages
                                                                .length -
                                                            index -
                                                            1]
                                                        .length >
                                                    1)
                                                  TextSpan(
                                                      text:
                                                          ' +${orderPackages[orderPackages.length - index - 1].length - 1}')
                                              ]),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                            orderDetails[orderPackages.length -
                                                index -
                                                1][0]['size'],
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          formatCurrency.format(double.parse(
                                              userPurchaseHistory[
                                                  orderPackages.length -
                                                      index -
                                                      1]['total'])),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .buttonColor
                                                  .withOpacity(0.75),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(height: 10),
                                      Text(
                                        DateFormat.yMd().format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(userPurchaseHistory[
                                                    orderPackages.length -
                                                        index -
                                                        1]['created']))),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                179, 179, 182, 1)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ));
  }
}
