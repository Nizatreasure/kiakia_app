import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final String uid, toID, timestamp, groupID;
  DatabaseService({this.uid, this.toID, this.timestamp, this.groupID});

  final DatabaseReference users = FirebaseDatabase.instance.reference();

  //creates a document for the user in the database during signUp
  Future createUser({name, number, email, url, isNumberVerified, provider}) async {
    return await users.child('users').child(uid).set({
      'name': name,
      'number': number ?? '',
      'isNumberVerified': isNumberVerified,
      'provider': provider,
      'email': email,
      'pictureURL': url ?? '',
    });
    //TODO: remember to remove the pass
  }
}
