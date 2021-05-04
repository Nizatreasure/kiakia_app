import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:kiakia/login_signup/decoration2.dart';
import 'package:kiakia/login_signup/services/authentication.dart';

//builds the dialog box for resetting user password when the forgot password button is pressed
forgotPasswordPopUp(BuildContext myContext) {
  AuthenticationService _auth = AuthenticationService();
  final _resetFormKey =
      GlobalKey<FormState>(); //the formKey used for validating the form
  String resetEmail, resetError = '';
  bool showLoaderAndResetError = false, showResetLoader = false;

  return showDialog(
      context: myContext,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Text(
                        'Enter your email address: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 7),
                      child: Form(
                        key: _resetFormKey,
                        child: TextFormField(
                          style: TextStyle(
                              height: 1.5,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                          decoration: decoration2.copyWith(
                            hintText: 'Email address',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (val) {
                            setState(() {
                              resetEmail = val;
                              resetError = '';
                            });
                          },
                          validator: (val) {
                            return EmailValidator.validate(val.trimRight())
                                ? null
                                : 'Email is not valid';
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                    ),
                    showLoaderAndResetError
                        ? Center(
                            child: showResetLoader
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ))
                                : Text(
                                    resetError,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                          )
                        : Text(''),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16),
                            )),
                        Spacer(),
                        MaterialButton(
                          elevation: 0,
                          textColor: Colors.blue,
                          onPressed: () async {
                            if (_resetFormKey.currentState.validate()) {
                              setState(() {
                                showLoaderAndResetError = true;
                                showResetLoader = true;
                              });
                              dynamic result =
                                  await _auth.resetUserPassword(resetEmail);
                              setState(() {
                                showResetLoader = false;
                              });
                              if (result == null) {
                                setState(() {
                                  resetError = _auth.error;
                                });
                              } else {
                                Navigator.pop(context);
                                successfulPasswordResetMail(
                                    email: resetEmail, context: myContext);
                              }
                            }
                          },
                          child: Text(
                            'Reset password',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      });
}

//shows a dialog if a password reset mail has been sent to the user
successfulPasswordResetMail({String email, BuildContext context}) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: RichText(
              text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(text: 'A password reset mail has been sent to '),
                    TextSpan(
                        text: email,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500)),
                  ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(fontSize: 17),
                ))
          ],
        );
      });
}
