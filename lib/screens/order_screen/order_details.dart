import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:kiakia/login_signup/decoration.dart';
import 'package:kiakia/login_signup/services/database.dart';
import 'package:kiakia/screens/order_screen/order_received.dart';
import 'package:localstorage/localstorage.dart';
import 'package:min_id/min_id.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetails extends StatefulWidget {
  final Map details, location;
  final String scheduledDate;
  OrderDetails({this.details, this.location, this.scheduledDate});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  var publicKey = 'pk_test_bba9b518a65c34b9623a02208a70c3ab8a52a4e4';
  final crypt = new PlatformStringCryptor();
  final key =
      'Jv/hw3jV2+y1kExPu8K+4Q==:ZQGMuXw+5hZZxE0ORsPAhkMAj68d8uNboEUcq9gQIQc=';
  final storage = new LocalStorage('user_data.json');
  String email = '', name = '', number = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String phoneNumber = '+2348117933576';
  String selectedPaymentMethod;
  final formatCurrency =
      new NumberFormat.currency(locale: 'en_US', symbol: '\u{20A6} ');
  String googleApiKey = 'AIzaSyDuc6Wz_ssKWEiNA4xJyUzT812LZgxnVUc';
  GoogleMapController _mapController;
  double orderTotal = 0;
  double total = 0;

  //responsible for launching the phone call app from within this app
  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //calculates the total price
  calculateTotalPrice() {
    widget.details.forEach((key, value) {
      orderTotal = orderTotal + double.parse(value['amount']);
    });
    total = orderTotal;
  }

  //gets the user details from local storage
  getUserDetails() async {
    await storage.ready;
    Map data = await storage.getItem('userData');
    if (data != null) {
      email = data['email'];
      number = data['number'];
      name = data['name'];
    }
  }

  //shows the status of the transaction, i.e if it was successful or not
  void showPaymentStatusReport(String status) {
    Navigator.pop(context);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 20,
                  width: 60,
                  child: Image.asset(
                    'assets/gas_logo2.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    status == 'success'
                        ? Icon(
                            Icons.check_box,
                            color: Colors.green,
                            size: 30,
                          )
                        : Icon(
                            Icons.backspace,
                            size: 30,
                            color: Colors.red,
                          ),
                    SizedBox(width: 10),
                    Text(
                      status == 'success'
                          ? 'Transaction Successful'
                          : 'Transaction failed. Try again',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (status == 'success') {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderReceived()));
                    }
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  )),
            ],
          );
        });
  }

  //gets an access code for the transaction
  Future<String> getAccessCode(
      {String payKey, String ref, int amount, String email}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $payKey'
    };
    Map data = {
      "amount": amount,
      "email": "$email",
      'reference': "$ref",
    };
    String payload = json.encode(data);
    Response response = await post(
        'https://api.paystack.co/transaction/initialize',
        headers: headers,
        body: payload);
    final Map theData = jsonDecode(response.body);
    String accessCode = theData['data']['access_code'];
    return accessCode;
  }

  saveAddressToDevice({address, lat, lng}) async {
    Map<String, dynamic> location = new Map();
    location['address'] = address;
    location['lat'] = lat;
    location['lng'] = lng;
    await storage.setItem('location', location);
  }

  //verifies the status of the payment by making a http request
  void verifyPayment(
      String reference, String payKey, int amount, paymentMethod) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $payKey'
      };
      Response response = await get(
          'https://api.paystack.co/transaction/verify/' + reference,
          headers: headers);
      final Map body = json.decode(response.body);
      showPaymentStatusReport(body['data']['status']);
      await DatabaseService(
              timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
              uid: FirebaseAuth.instance.currentUser.uid)
          .createNewGasOrder(
              reference: reference,
              number: number,
              name: name,
              order: widget.details,
              location: widget.location,
              total: total.toString(),
              paymentMethod: paymentMethod,
              schedule: widget.scheduledDate,
              transactionID: MinId.getId('4{w}2{d}3{w}2{d}1{w}'));
      saveAddressToDevice(
          address: widget.location['address'],
          lat: widget.location['lat'],
          lng: widget.location['lng']);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    calculateTotalPrice();
    PaystackPlugin.initialize(publicKey: publicKey);
    getUserDetails();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
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
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 15, 20),
            child: Text(
              'Order Summary',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: widget.details.keys.map((package) {
              return Container(
                color: Color.fromRGBO(244, 246, 248, 1),
                padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
                margin: EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      child: Text(widget.details[package]['quantity'],
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
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
                          Text(package,
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
                          Text(widget.details[package]['size'],
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
                            double.parse(widget.details[package]['amount'])),
                        style: TextStyle(
                            color:
                                Theme.of(context).buttonColor.withOpacity(0.75),
                            fontSize: 18,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
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
                  formatCurrency.format(total),
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
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Text(
              'Address',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: Text(widget.location['address']),
          ),

          //this container holds the map of the delivery address
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              height: 150,
              child: GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                    target:
                        LatLng(widget.location['lat'], widget.location['lng']),
                    zoom: 18),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: {
                  Marker(
                    markerId: MarkerId('id'),
                    position:
                        LatLng(widget.location['lat'], widget.location['lng']),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                    infoWindow: InfoWindow(
                      title: 'Delivery Location',
                    ),
                  ),
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          if (widget.scheduledDate != null && widget.scheduledDate.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule Refill Date',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Text(widget.scheduledDate),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Text(
              'Payment',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Text('Select preferred payment method below',
                style: Theme.of(context).textTheme.bodyText2),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
            child: DropdownButtonFormField(
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 28,
                color: Color.fromRGBO(179, 179, 182, 1),
              ),
              style: TextStyle(fontSize: 20, color: Colors.black),
              decoration:
                  decoration.copyWith(hintText: 'Select Payment Method'),
              items: [
                DropdownMenuItem(
                  child: Text(
                    'Card',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: 'Card',
                ),
                DropdownMenuItem(
                  child: Text(
                    'Bank',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: 'Bank',
                ),
                DropdownMenuItem(
                  child: Text(
                    'Pay on delivery',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: 'Pay on delivery',
                ),
              ],
              value: selectedPaymentMethod,
              onChanged: (val) {
                setState(() {
                  selectedPaymentMethod = val;
                });
              },
            ),
          ),
          InkWell(
            onTap: () async {
              if (selectedPaymentMethod == null) {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red[900],
                    content: Text(
                      'Please select a payment method',
                      style: TextStyle(fontSize: 18),
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              if (selectedPaymentMethod == 'Card' ||
                  selectedPaymentMethod == 'Bank') {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return Container();
                    });
                try {
                  final snapshot = await FirebaseDatabase.instance
                      .reference()
                      .child('keys')
                      .child('app_key')
                      .once();
                  String payKey = await crypt.decrypt(snapshot.value, key);
                  Charge charge = Charge();
                  charge
                    ..card = PaymentCard(
                        number: null,
                        cvc: null,
                        expiryMonth: null,
                        expiryYear: null)
                    ..amount = (total * 100).toInt()
                    ..email = email
                    ..reference = MinId.getId('4{w}2{d}5{w}1{d}6{w}2{d}1{w}')
                    ..accessCode = await getAccessCode(
                      payKey: payKey,
                      ref: charge.reference,
                      amount: charge.amount,
                      email: charge.email,
                    );

                  Navigator.pop(context);
                  CheckoutResponse response = await PaystackPlugin.checkout(
                    context,
                    method: selectedPaymentMethod == 'Card'
                        ? CheckoutMethod.card
                        : CheckoutMethod.bank,
                    charge: charge,
                    fullscreen: false,
                    logo: Container(
                      width: 80,
                      child: Image.asset(
                        'assets/gas_logo2.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  );

                  if (response.status == true) {
                    //this dialog is just used to prevent user input till the verification status of the transaction is confirmed
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return Container();
                        });
                    verifyPayment(response.reference, payKey, charge.amount,
                        selectedPaymentMethod);
                  }
                } catch (e) {
                  Navigator.pop(context);
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red[900],
                      content: Text(
                        'An error occurred. Try again',
                        style: TextStyle(fontSize: 18),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
              if (selectedPaymentMethod == 'Pay on delivery') {
                bool disableButton = false;
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            content: RichText(
                              text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                  children: [
                                    TextSpan(text: 'Pay   '),
                                    TextSpan(
                                        text:
                                            '${formatCurrency.format(total)}  ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900)),
                                    TextSpan(text: 'cash on delivery?')
                                  ]),
                            ),
                            actions: [
                              FlatButton(
                                  onPressed: disableButton
                                      ? null
                                      : () {
                                          Navigator.pop(context);
                                        },
                                  child: Text('NO')),
                              FlatButton(
                                  onPressed: disableButton
                                      ? null
                                      : () async {
                                          setState(() {
                                            disableButton = true;
                                          });
                                          try {
                                            final response = await get(
                                                'https://www.google.com');
                                            if (response.statusCode == 200) {
                                              DatabaseService(
                                                      timestamp: DateTime.now()
                                                          .millisecondsSinceEpoch
                                                          .toString(),
                                                      uid: FirebaseAuth.instance
                                                          .currentUser.uid)
                                                  .createNewGasOrder(
                                                      number: number,
                                                      name: name,
                                                      order: widget.details,
                                                      location: widget.location,
                                                      total: total.toString(),
                                                      paymentMethod: 'Cash',
                                                      schedule:
                                                          widget.scheduledDate,
                                                      transactionID: MinId.getId(
                                                          '4{w}2{d}3{w}2{d}1{w}'))
                                                  .then((value) async {
                                                await saveAddressToDevice(
                                                    address: widget
                                                        .location['address'],
                                                    lat: widget.location['lat'],
                                                    lng:
                                                        widget.location['lng']);
                                                showPaymentStatusReport(
                                                    'success');
                                              });
                                            }
                                          } catch (e) {
                                            Navigator.pop(context);
                                            _scaffoldKey.currentState
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    Colors.red[900],
                                                content: Text(
                                                  'An error occurred. Try again',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        },
                                  child: disableButton
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator())
                                      : Text('YES')),
                            ],
                          );
                        },
                      );
                    });
              }
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(30, 10, 30, 30),
              color: Theme.of(context).accentColor,
              child: Text(
                'Pay Now',
                style:
                    Theme.of(context).textTheme.button.copyWith(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
