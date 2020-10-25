import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiakia/login_signup/decoration.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:flutter/custom_flutter/custom_dialog.dart' as customDialog;

//creates a dialog box asking a user to enter a new number
Future<void> changeUserNumber(BuildContext myContext) async {
  String number;
  final _changeNumberFormKey = GlobalKey<FormState>();
  return showDialog<void>(
      context: myContext,
      barrierDismissible: false,
      builder: (context) {
        return customDialog.Dialog(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter New Number',
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                        key: _changeNumberFormKey,
                        child: TextFormField(
                          style: TextStyle(
                              height: 1.5,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                          decoration: decoration.copyWith(
                              hintText: 'Enter number here', counterText: ''),
                          validator: (val) {
                            if (val.trim().length != 11) {
                              return 'Phone number must be 11 digits long';
                            } else
                              return null;
                          },
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          maxLength: 11,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            number = val;
                            if (val.length == 11) {
                              FocusScope.of(context).focusedChild.unfocus();
                            }
                          },
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Spacer(),
                        FlatButton(
                            onPressed: () async {
                              if (_changeNumberFormKey.currentState
                                  .validate()) {
                                Navigator.pop(context);
                                await updateUserNumberDetails(
                                    number, myContext);
                              }
                            },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
}

//responsible for updating a user number in the database and then calling the verify number function to verify the new number
Future<void> updateUserNumberDetails(
    String number, BuildContext myContext) async {
  final uid = FirebaseAuth.instance.currentUser.uid;
  final snapshot = await FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uid)
      .once();

  //if an account is already associated with the user, first unlink the number before registering a new one
  if (snapshot.value['isNumberVerified'] == true) {
    await unlinkNumber();
  }

  //updates the number in the database
  await FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uid)
      .update({'number': '+234' + number.substring(1, 11)});

  //shows  the number not verified popup and asks the user to verify their number
  numberNotVerifiedPopup('+234' + number.substring(1, 11), myContext);
}

//creates a dialog box that notifies the user whose phone number has not been verified to verify it
Future<void> numberNotVerifiedPopup(
    String number, BuildContext myContext) async {
  return showDialog<void>(
      context: myContext,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: RichText(
              text: TextSpan(
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                  children: [
                TextSpan(text: 'Number not verified: '),
                TextSpan(
                    text: '0' + number.substring(4, 14),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))
              ])),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            FlatButton(
              onPressed: () async {
                await AuthenticationService().verifyNumber(
                    number: number,
                    myContext:
                        myContext); // calls the function that starts the number verification process
              },
              child: Text('Verify Now'),
            ),
          ],
        );
      });
}

//unlink the number currently associated with user account
Future<void> unlinkNumber() async {
  await FirebaseAuth.instance.currentUser.unlink('phone');
  await FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(FirebaseAuth.instance.currentUser.uid)
      .update({
    'isNumberVerified': false,
  });
}
