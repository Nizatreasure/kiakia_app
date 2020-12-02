import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kiakia/login_signup/decoration.dart';
import 'package:kiakia/login_signup/services/change_user_number.dart';
import 'package:kiakia/login_signup/services/database.dart';
import 'package:flutter/custom_flutter/custom_dialog.dart' as customDialog;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String error = '';
  final secureStorage = new FlutterSecureStorage();

  //signs in the user with email and password
  Future signInWithEmailAndPassword({email, password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      String token = await FirebaseMessaging().getToken();
      User user = result.user;
      await FirebaseDatabase.instance
          .reference()
          .child('gas_monitor')
          .child(user.uid)
          .update({'token': token});
      await secureStorage.write(key: 'password', value: password);
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        error = 'Password is incorrect';
      } else if (e.code == 'user-not-found') {
        error = 'User does not exist';
      } else if (e.code == 'network-request-failed') {
        error = 'Network request failed';
      } else if (e.code == 'user-disabled') {
        error = 'User has been disabled';
      } else if (e.code == 'too-many-requests') {
        error = 'Too many attempts';
      }
      else {
        error = 'Unknown error';
      }
      print(e.code);
      return null;
    } catch (e) {
      error = 'Could not sign in';
      return null;
    }
  }

  //constructs the dialog box where users can enter their otp to be verified
  Future<void> showOtpDialog(BuildContext myContext, verId, number) async {
    String smsCode, otpError = '';
    bool showLoaderAndError = false, showLoader = false;
    TextEditingController _controller = TextEditingController();
    _controller.addListener(() {});
    return showDialog<void>(
        context: myContext,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return customDialog.Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: 'An SMS code has been sent to '),
                                    TextSpan(
                                        text: '0${number.substring(4, 14)}',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold))
                                  ])),
                          SizedBox(
                            height: 10,
                          ),
                          TextField(
                            autofocus: true,
                            controller: _controller,
                            decoration: decoration.copyWith(
                                hintText: 'Enter code here',
                                hintStyle: TextStyle(fontSize: 20)),
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                fontSize: 24,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w500),
                            onChanged: (val) {
                              setState(() {
                                smsCode = val.trim();
                              });
                            },
                          ),

                          //displays a progress indicator when the verify button is clicked. the loader changes to an error message if an error occurred
                          showLoaderAndError
                              ? Center(
                                  child: showLoader
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: CircularProgressIndicator(),
                                        )
                                      : Text(
                                          otpError,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                )
                              : Text(''),

                          //the change number and verify buttons  are created inside a row
                          Row(
                            children: [
                              FlatButton(
                                  onPressed: () {

                                      Navigator.pop(context);
                                      changeUserNumber(
                                          myContext, 'Enter New Number');
                                  },
                                  child: Text(
                                    'Change Number',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.blue),
                                  )),
                              Spacer(),
                              FlatButton(
                                  textColor: Colors.blue,
                                  onPressed: _controller.text.trim().length < 4
                                      ? null
                                      : () async {
                                          setState(() {
                                            showLoaderAndError = true;
                                            showLoader = true;
                                          });
                                          //creates a credential for the user using the otp code inputted
                                          PhoneAuthCredential credential =
                                              PhoneAuthProvider.credential(
                                                  verificationId: verId,
                                                  smsCode: smsCode);
                                          //links the number entered by the user to their current email. it displays an error message if the operation was not successful
                                          try {
                                            otpError = '';
                                              await _auth.currentUser
                                                  .linkWithCredential(
                                                      credential);
                                              await FirebaseDatabase.instance
                                                  .reference()
                                                  .child('users')
                                                  .child(_auth.currentUser.uid)
                                                  .update({
                                                'isNumberVerified': true
                                              });
                                              Navigator.pop(context);
                                          } on FirebaseAuthException catch (e) {
                                            setState(() {
                                              showLoader = false;
                                              if (e.code ==
                                                  'credential-already-in-use') {
                                                otpError =
                                                    'This number is already associated with another user account';
                                              } else if (e.code ==
                                                  'invalid-verification-code') {
                                                otpError =
                                                    'Invalid verification code';
                                              } else if (e.message ==
                                                  'com.google.firebase.FirebaseException: User has already been linked to the given provider.') {
                                                otpError =
                                                    'A number has already been linked with this account';
                                              } else
                                                otpError = 'An error occurred';
                                            });

                                            return null;
                                          } catch (e) {
                                            setState(() {
                                              otpError = 'An error occurred';
                                            });
                                          }
                                        },
                                  child: Text(
                                    'Verify',
                                    style: TextStyle(fontSize: 17),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

//creates an account for the user with email and password
  Future createAccount(
      {email, password, number, name, isNumberVerified}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      String token = await FirebaseMessaging().getToken();

      //creates a database document for the user based on their firebase id
      await DatabaseService(uid: user.uid).createUser(
          name: name,
          number: number,
          email: email,
          isNumberVerified: isNumberVerified,
          provider: 'email');
      await  DatabaseService(uid: user.uid).createGasMonitor(token);
      await secureStorage.write(key: 'password', value: password);

      //updates the firebase display name of the user to the name inputted
      await _auth.currentUser.updateProfile(displayName: name);
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        error = 'Email already in use';
      } else if (e.code == 'invalid-email') {
        error = 'Email is not valid';
      } else if (e.code == 'network-request-failed') {
        error = 'Network request failed';
      } else if (e.code == 'weak-password') {
        error = 'Password is too weak';
      } else {
        error = 'Unknown Error';
      }
      return null;
    } catch (e) {
      error = 'Could not Create account';
      return null;
    }
  }

  //the function responsible for initiating the process of  number verification when the user clicks on the 'verify now' button on the pop up
  //an id of 1 logs in users while other ids would link the user credentials
  Future verifyNumber({number, BuildContext myContext}) async {

     int _resendToken;
     try {
       await _auth.verifyPhoneNumber(
           phoneNumber: number,
           forceResendingToken: _resendToken,
           verificationCompleted: (phoneAuthCredentials) async {

               await _auth.currentUser.linkWithCredential(phoneAuthCredentials);
               await FirebaseDatabase.instance
                   .reference()
                   .child('users')
                   .child(_auth.currentUser.uid)
                   .update({'isNumberVerified': true});
               Navigator.pop(myContext);
             },
           verificationFailed: (FirebaseAuthException e) {
             if (e.code == 'too-many-requests') {
               error = 'Too many attempts, try again later';
             } else if (e.code == 'network-request-failed') {
               error = 'Network request failed, try again later';
             } else {
               error = 'Request failed, try again later';
             }
             return null;
           },
           codeSent: (verId, int resendToken) async {
             _resendToken = resendToken;
             showOtpDialog(myContext, verId, number);
           },
           timeout: Duration(seconds: 30),
           codeAutoRetrievalTimeout: (verificationID) {});
     } on FirebaseAuthException catch (e) {
       if (e.code == 'network-request-failed') {
         error = 'Network request failed';
       } else {
         error = 'Unknown Error';
       }
       return null;
     } catch (e) {
       error = 'An error occurred';
       return null;
     }

  }

  //signs the user out of the application
  Future logOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  //sends a password reset mail to registered users who have forgotten their password
  Future resetUserPassword(email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      print('error: $e');
      if (e.code == 'user-not-found') {
        error = 'User does not exist';
      } else if (e.code == 'invalid-email') {
        error = 'Email is not valid';
      } else
        error = 'An error occurred. Try again later';
      return null;
    }
  }

  //listens for changes in the user account such as sign in and sign out
  Stream<User> get user {
    return _auth.authStateChanges();
  }
}
