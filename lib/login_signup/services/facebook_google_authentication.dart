import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:kiakia/login_signup/services/database.dart';
import 'package:kiakia/screens/dashboard.dart';

Future facebookLogin(context) async {
  final fb = FacebookLogin();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();
  myLoader(context);
  final result = await fb.logIn(['email', 'public_profile']);
  dynamic userExists;

  switch (result.status) {
    case FacebookLoginStatus.loggedIn:
      String firebaseMessagingToken = await FirebaseMessaging().getToken();
      //get the user token when log in is successful
      final String token = result.accessToken.token;

      //get profile information from the user account
      final response = await get(Uri.encodeFull(
          'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token'));
      final profile = jsonDecode(response.body);

      //convert the user token into a firebase auth credential
      final credential = FacebookAuthProvider.credential(token);

      //sign in the user with the credential
      try {
        final user = await _auth.signInWithCredential(credential);

        //query database to know if the user already has data stored
        final data = await _database.child('users').child(user.user.uid).once();
        userExists = data.value;

        if (userExists == null) {
          await DatabaseService(uid: user.user.uid).createUser(
              name: profile['name'],
              email: profile['email'],
              url: profile['picture']['data']['url'],
              isNumberVerified: false,
              provider: 'facebook');
          await DatabaseService(uid: user.user.uid)
              .createGasMonitor(firebaseMessagingToken);
          await _auth.currentUser.updateProfile(displayName: profile['name']);
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Dashboard()));
        } else {
          DataSnapshot snapshot = await FirebaseDatabase.instance
              .reference()
              .child('roles')
              .child(user.user.uid)
              .once();
          if (snapshot.value['role'] == 'user') {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Dashboard()));
            await FirebaseDatabase.instance
                .reference()
                .child('gas_monitor')
                .child(user.user.uid)
                .update({'token': token});
          } else {
            Navigator.pop(context);
            await _auth.signOut();
            return errorDialog(context, 'User not found');
          }
        }
      } catch (e) {
        Navigator.pop(context);
        if (e.code == 'account-exists-with-different-credential')
          return errorDialog(context,
              'An account already exists with the associated email. Please try another sign in method');
        else
          return errorDialog(context, 'An error occurred, please try again');
      }

      break;

    //displays a dialog box when an error occurred during facebook signUp
    case FacebookLoginStatus.error:
      Navigator.pop(context);
      errorDialog(context, 'An error occurred, please try again');
      break;
    case FacebookLoginStatus.cancelledByUser:
      Navigator.pop(context);
      Container(
        height: 0,
        width: 0,
      );
      break;
  }
}

Future googleSignIn(context) async {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();
  dynamic userExists;
  String firebaseMessagingToken = await FirebaseMessaging().getToken();
  GoogleSignIn _google = GoogleSignIn(
    scopes: ['email'],
  );

  try {
    myLoader(context);
    final result = await _google.signIn();
    final authentication = await result.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken);

    final user = await _auth.signInWithCredential(credential);

    //query database to know if the user already has data stored
    final data = await _database.child('users').child(user.user.uid).once();
    userExists = data.value;

    if (userExists == null) {
      await DatabaseService(uid: user.user.uid).createUser(
          name: user.user.displayName,
          email: user.user.email,
          url: user.user.photoURL == null ? '' : user.user.photoURL,
          isNumberVerified: false,
          provider: 'google');

      await DatabaseService(uid: user.user.uid)
          .createGasMonitor(firebaseMessagingToken);
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Dashboard()));
    } else {
      DataSnapshot snapshot = await FirebaseDatabase.instance
          .reference()
          .child('roles')
          .child(user.user.uid)
          .once();
      if (snapshot.value['role'] == 'user') {
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
        await _database
            .child('users')
            .child(user.user.uid)
            .update({'provider': 'google'});
        await FirebaseDatabase.instance
            .reference()
            .child('gas_monitor')
            .child(user.user.uid)
            .update({'token': firebaseMessagingToken});
      } else {
        Navigator.pop(context);
        await _auth.signOut();
        return errorDialog(context, 'User not found');
      }
    }
  } catch (e) {
    print(e.code);
    Navigator.pop(context);
    return errorDialog(context, 'An error occurred, please try again');
  }
}

Future errorDialog(context, text) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            text,
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(fontSize: 18),
                ))
          ],
        );
      });
}

Future myLoader(context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Container(
          child: Center(child: CircularProgressIndicator()),
        );
      });
}
