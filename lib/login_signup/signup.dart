import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kiakia/login_signup/decoration.dart';
import 'package:flutter/services.dart'; //necessary for using inputFormatter to receive numbers only
import 'package:kiakia/login_signup/services/authentication.dart';

class SignUp extends StatefulWidget {
  final Function togglePage;
  SignUp(this.togglePage);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthenticationService _auth = AuthenticationService();
  ScrollController _scrollController;
  bool _hidePassword =
      true; // controls the visibility of the password a user enters
  final _formKey = GlobalKey<
      FormState>(); //controls the form used for inputting email, phone number and password
  bool showLoader = false;
  bool showLoaderAndError = false;
  FocusNode _passwordFocusNode;
  String number = '', password = '', name = '', email = '';
  String errorMessage = '';
  TextEditingController _numberController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _passwordFocusNode.addListener(() {
      //hides the password when a user focus changes from the password field
      if (!_passwordFocusNode.hasFocus) {
        _hidePassword = true;
      }
    });
    _scrollController = new ScrollController();
    _scrollController.addListener(() {});
    _numberController.addListener(() {});
  }

  //queries the database to ensure that a number can also be used to sign up once.
  //returns false if the number exists and true if it doesn't exist in the database
  Future<String> _numberNotUsedByAnotherClient(String num) async {
    List userNumbers = new List();
    try {
      final response = await get('https://www.google.com');
      if (response.statusCode == 200) {
        DataSnapshot snapshot =
            await FirebaseDatabase.instance.reference().child('users').once();
        if (snapshot != null) {
          Map data = snapshot.value;
          data.forEach((key, value) {
            userNumbers.add(value['number']);
          });
        }
      }
      return userNumbers.contains('+234' + num.substring(1, 11))
          ? 'exists'
          : 'notExist';
    } catch (e) {
      return 'network-error';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //gets the width of the current device from mediaQuery
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: LayoutBuilder(
            builder: (context, viewport) {
              return SingleChildScrollView(
                controller: _scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: width >= 560
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Spacer(
                          flex: 3,
                        ),
                        Container(
                          height: 80,
                          alignment: width >= 560
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: Text('SignUp',
                              style: TextStyle(
                                  color: Color.fromRGBO(77, 172, 246, 1),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w500)),
                        ),
                        Spacer(
                          flex: 2,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                //creates a formfield where users input their names
                                TextFormField(
                                  onChanged: (val) {
                                    name = val.trim();
                                  },
                                  textCapitalization: TextCapitalization.words,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  decoration: decoration.copyWith(
                                      labelText: 'Name',
                                      hintText: 'Enter your name'),
                                  validator: (val) {
                                    if (val.trim().isEmpty)
                                      return 'Field cannot be empty';
                                    else
                                      return null;
                                  },
                                ),
                                SizedBox(height: 10),

                                //creates the field for entering the user email during signUp
                                TextFormField(
                                  onChanged: (val) {
                                    email = val;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  decoration: decoration.copyWith(
                                      labelText: 'Email',
                                      hintText: 'Enter your email'),
                                  validator: (val) {
                                    return EmailValidator.validate(
                                            val.trimRight())
                                        ? null
                                        : 'Email is not valid';
                                  },
                                ),
                                SizedBox(height: 10),

                                //creates the field for entering mobile phone number during signUp
                                TextFormField(
                                  controller: _numberController,
                                  onChanged: (val) {
                                    number = val;
                                    if (val.length == 11) {
                                      FocusScope.of(context)
                                          .focusedChild
                                          .unfocus();
                                      _passwordFocusNode.requestFocus();
                                    }
                                  },
                                  maxLength: 11,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  validator: (val) {
                                    if (val.trim().length != 11) {
                                      return 'Phone number must be 11 digits long';
                                    } else
                                      return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11)
                                  ], //makes the textField receive only digits
                                  decoration: decoration.copyWith(
                                      labelText: 'Phone Number',
                                      hintText: 'Enter your phone number',
                                      counterText: ''),
                                ),
                                SizedBox(height: 10),

                                //creates the field for entering password during signUp
                                TextFormField(
                                  onChanged: (val) {
                                    password = val;
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  validator: (val) {
                                    if (val.trim().isEmpty) {
                                      return 'Password cannot be empty';
                                    } else if (val.trim().length < 5) {
                                      return 'Password cannot be less than 5 character';
                                    } else
                                      return null;
                                  },
                                  focusNode: _passwordFocusNode,
                                  decoration: decoration.copyWith(
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.remove_red_eye,
                                            color: _hidePassword
                                                ? Color.fromRGBO(
                                                    138, 136, 136, 1)
                                                : Color.fromRGBO(
                                                    15, 125, 188, 1)),
                                        onPressed: () {
                                          setState(() {
                                            _hidePassword = !_hidePassword;
                                          });
                                        },
                                      )),
                                  obscureText: _hidePassword,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Already have an account?',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          widget.togglePage(2);
                                        },
                                        child: Text(
                                          'Sign-in',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17,
                                              color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 50),

                                //creates the signUp button
                                InkWell(
                                  onTap: () async {
                                    errorMessage =
                                        ''; //resets the error message to an empty string
                                    if (!FocusScope.of(context)
                                            .hasPrimaryFocus &&
                                        FocusScope.of(context).focusedChild !=
                                            null) {
                                      FocusScope.of(context)
                                          .focusedChild
                                          .unfocus();
                                    }
                                    //attempts to create an account for the user with email and password. displays an error message if an error occurred
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        showLoaderAndError = true;
                                        showLoader = true;
                                        _scrollController.jumpTo(
                                            _scrollController
                                                .position.maxScrollExtent);
                                      });
                                      if (await _numberNotUsedByAnotherClient(
                                              number) ==
                                          'notExist') {
                                        dynamic result =
                                            await _auth.createAccount(
                                                password: password,
                                                number: '+234' +
                                                    number.substring(1, 11),
                                                email: email,
                                                name: name,
                                                isNumberVerified: false);
                                        if (mounted) {
                                          setState(() {
                                            showLoader = false;
                                          });
                                        }
                                        if (result == null) {
                                          errorMessage = _auth.error;
                                        }
                                      } else if (await _numberNotUsedByAnotherClient(
                                              number) ==
                                          'exists') {
                                        if (mounted)
                                          setState(() {
                                            showLoader = false;
                                            errorMessage =
                                                'Number already used';
                                          });
                                      } else {
                                        setState(() {
                                          showLoader = false;
                                          errorMessage = 'Network error';
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color.fromRGBO(15, 125, 188, 1)),
                                    child: Text(
                                      'SignUp',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(246, 248, 250, 1),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        showLoaderAndError
                            ? Container(
                                height: 50,
                                child: Center(
                                  child: showLoader
                                      ? CircularProgressIndicator()
                                      : Text(
                                          errorMessage,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                ),
                              )
                            : Text(''),
                        Spacer(
                          flex: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
