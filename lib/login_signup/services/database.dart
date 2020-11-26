import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final String uid, toID, timestamp, groupID;
  DatabaseService({this.uid, this.toID, this.timestamp, this.groupID});
  
  final DatabaseReference users = FirebaseDatabase.instance.reference();

  //creates a document for the user in the database during signUp
  Future createUser(
      {name, number, email, url, isNumberVerified, provider}) async {
    return await users.child('users').child(uid).set({
      'name': name,
      'number': number ?? '',
      'isNumberVerified': isNumberVerified,
      'provider': provider,
      'email': email,
      'pictureURL': url ?? '',
    });
  }

  //creates a document for saving the user gas level and device
  // token which would be used to send push notifications
  Future createGasMonitor() async {
    return await users
        .child('gas_monitor')
        .child(uid)
        .set({'token': '', 'gas_level': 0.0});
  }

  //updates the database when a user makes a gas purchase
  Future createNewGasOrder(
      {String reference,
      Map order,
      String name,
      Map location,
      String number, String transactionID, String paymentMethod, String total, String deliveryCharge}) async {
    await users.child('orders').child('personalOrders').child(uid).push().set({
      'reference': reference,
      'created': timestamp,
      'status': 'Pending',
      'order': order,
      'deliveryCharge': deliveryCharge,
      'total': total,
      'location': location,
      'transactionID': transactionID,
      'paymentMethod': paymentMethod
    });
    return await users.child('orders').child('pendingOrders').push().set({
      'name': name,
      'created': timestamp,
      'order': order,
      'location': location,
      'total': total,
      'number': number,
      'transactionID': transactionID,
      'paymentMethod': paymentMethod

    });
  }
}
