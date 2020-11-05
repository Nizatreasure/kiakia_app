import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:min_id/min_id.dart';
import 'package:localstorage/localstorage.dart';

class PaystackPayment extends StatefulWidget {
  @override
  _PaystackPaymentState createState() => _PaystackPaymentState();
}

class _PaystackPaymentState extends State<PaystackPayment> {
  var publicKey = 'pk_test_bba9b518a65c34b9623a02208a70c3ab8a52a4e4';
  final crypt = new PlatformStringCryptor();
  final key =
      'Jv/hw3jV2+y1kExPu8K+4Q==:ZQGMuXw+5hZZxE0ORsPAhkMAj68d8uNboEUcq9gQIQc=';
  final storage = new LocalStorage('user_data.json');
  String email = '';

  @override
  void initState() {
    PaystackPlugin.initialize(publicKey: publicKey);
    super.initState();
    getUserEmail();
  }

  getUserEmail() async {
    await storage.ready;
    Map data = await storage.getItem('userData');
    if (data != null) email = data['email'];
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

  //verifies the status of the payment by making a http request
  void verifyPayment(String reference, String payKey) async {
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
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    int amount = 500000;
    return Center(
      child: FlatButton(
        child: Text('Click me'),
        onPressed: () async {
          final snapshot = await FirebaseDatabase.instance
              .reference()
              .child('keys')
              .child('app_key')
              .once();
          String payKey = await crypt.decrypt(snapshot.value, key);
          Charge charge = Charge();
          charge
            ..card = PaymentCard(
                number: null, cvc: null, expiryMonth: null, expiryYear: null)
            ..amount = amount * 100
            ..email = email
            ..reference = MinId.getId('4{w}2{d}5{w}1{d}6{w}2{d}1{w}')
            ..accessCode = await getAccessCode(
                payKey: payKey,
                ref: charge.reference,
                amount: charge.amount,
                email: charge.email);
          try {
            CheckoutResponse response = await PaystackPlugin.checkout(
              context,
              method: CheckoutMethod.card,
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
              verifyPayment(response.reference, payKey);
            }
          } catch (e) {}
        },
        color: Colors.blue,
      ),
    );
  }
}
