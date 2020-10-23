import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final String uid, toID, timestamp, groupID;
  DatabaseService({this.uid, this.toID, this.timestamp, this.groupID});

  final DatabaseReference users = FirebaseDatabase.instance.reference();

  //creates a document for the user in the database during signUp
  Future createUser({name, number, email}) async {
    return await users.child('users').child(uid).set({
      'name': name,
      'number': number,
      'isNumberVerified': false,
      'email': email
    });
  }
}
