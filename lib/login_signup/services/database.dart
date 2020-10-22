import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService  {
  final String uid, toID, timestamp, groupID;
  DatabaseService({this.uid,  this.toID, this.timestamp, this.groupID});

//  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final DatabaseReference users = FirebaseDatabase.instance.reference();





  Future createUser({name, number, email})  async {
    return await users.child('users').child(uid).set({'name': name, 'number': number, 'isNumberVerified': false, 'email': email});
  }




//
//  Future sendMessage (String content) async {
//  return await messages.doc(groupID).collection(groupID).doc(timestamp).set({
//    'fromID': uid,
//    'toID': toID,
//    'content': content,
//    'timestamp': timestamp
//  });
//  }


//  List<UserData> chatUsers (QuerySnapshot snapshot) {
//    return snapshot.docs.map((doc) {
//      return UserData(
//        uid: doc.id,
//        name: doc.data()['displayName'] ?? '',
//        number: doc.data()['phoneNumber'] ?? '',
//      );
//    }).toList();
//  }

//  UserData userData (DocumentSnapshot snapshot) {
//    return UserData(
//      uid: uid,
//      name: snapshot.data()['displayName'],
//      number: snapshot.data()['phoneNumber']
//    );
//  }
//  List<Messages> getUserMessages (QuerySnapshot snapshot) {
//    return snapshot.docs.map((doc) {
//      return Messages(
//        fromID: doc['fromID'],
//        toID: doc['toID'],
//        content: doc['content'],
//        timestamp: DateTime.fromMillisecondsSinceEpoch(int.parse(doc['timestamp'])),
//      );
//    }).toList();
//  }



//retrieves data from real time database

//Stream<Event> get userDetails {
//    return users.child('users').onValue;
//}



//  Stream <UserData> get userSingleData {
//    return users.doc(uid).snapshots().map(userData);
//  }
//
//  Stream<List<Messages>> get  userMessages {
//    return messages.doc(groupID).collection(groupID).orderBy('timestamp', descending: true).snapshots().map(getUserMessages);
//  }

  }