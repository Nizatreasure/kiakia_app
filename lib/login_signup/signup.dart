import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart'; //necessary for using inputFormatter to receive numbers only
import 'package:kiakia/login_signup/decoration2.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:kiakia/login_signup/services/facebook_google_authentication.dart';
import 'package:kiakia/screens/dashboard.dart';

class SignUp extends StatefulWidget {
  //togglePage toggles the login and sign up pages
  final Function togglePage;
  SignUp(this.togglePage);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthenticationService _auth = AuthenticationService();
  bool _hidePassword =
      true; // controls the visibility of the password a user enters
  final _formKey = GlobalKey<
      FormState>(); //controls the form used for inputting email, phone number and password
  bool showLoader = false;
  bool showError = false;
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
    _numberController.addListener(() {});
  }

  //queries the database to ensure that a number can also be used to sign up once.
  //returns false if the number exists and true if it doesn't exist in the database
  Future<String> _numberNotUsedByAnotherClient(String num) async {
    List userNumbers = [];
    try {
      final response = await get('https://www.google.com');
      if (response.statusCode == 200) {
        DataSnapshot snapshot =
            await FirebaseDatabase.instance.reference().child('users').once();
        DataSnapshot snapshot2 =
            await FirebaseDatabase.instance.reference().child('riders').once();
        if (snapshot != null) {
          Map data = snapshot.value;
          data.forEach((key, value) {
            userNumbers.add(value['number']);
          });
        }
        if (snapshot2 != null) {
          Map data = snapshot2.value;
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

  //formats the user's name by removing extra spaces
  String formatUserName(String name) {
    List nameList = [];
    for (int i = 0; i < name.split(' ').length; i++) {
      if (name.split(' ')[i] != '') nameList.add(name.split(' ')[i]);
    }
    return nameList.join(' ');
  }

  @override
  void dispose() {
    super.dispose();
    _numberController.dispose();
    _passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //gets the width of the current device from mediaQuery
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment:
          width >= 560 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Spacer(),
        Container(
          height: 70,
          alignment:
              width >= 560 ? Alignment.bottomCenter : Alignment.bottomLeft,
          child: Text(
            'Hello,',
            style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 32),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 50,
          alignment: width >= 560 ? Alignment.topCenter : Alignment.topLeft,
          child: Text(
            'Enter your details below or sign up with a social media account',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Spacer(),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //creates a formField where users input their names
                TextFormField(
                  onChanged: (val) {
                    name = val.trim();
                  },
                  textCapitalization: TextCapitalization.words,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textAlignVertical: TextAlignVertical.bottom,
                  style: TextStyle(
                      height: 1.5, fontSize: 18, fontWeight: FontWeight.w500),
                  decoration: decoration2.copyWith(hintText: 'Name'),
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textAlignVertical: TextAlignVertical.bottom,
                  style: TextStyle(
                      height: 1.5, fontSize: 18, fontWeight: FontWeight.w500),
                  decoration: decoration2.copyWith(hintText: 'Email'),
                  validator: (val) {
                    return EmailValidator.validate(val.trimRight())
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
                      FocusScope.of(context).focusedChild.unfocus();
                      _passwordFocusNode.requestFocus();
                    }
                  },
                  maxLength: 11,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textAlignVertical: TextAlignVertical.bottom,
                  style: TextStyle(
                      height: 1.5, fontSize: 18, fontWeight: FontWeight.w500),
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
                  decoration: decoration2.copyWith(
                      hintText: 'Phone Number', counterText: ''),
                ),
                SizedBox(height: 10),

                //creates the field for entering password during signUp
                TextFormField(
                  onChanged: (val) {
                    password = val;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textAlignVertical: TextAlignVertical.bottom,
                  style: TextStyle(
                      height: 1.5, fontSize: 18, fontWeight: FontWeight.w500),
                  validator: (val) {
                    if (val.trim().isEmpty) {
                      return 'Password cannot be empty';
                    } else if (val.trim().length < 5) {
                      return 'Password cannot be less than 5 character';
                    } else
                      return null;
                  },
                  focusNode: _passwordFocusNode,
                  decoration: decoration2.copyWith(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.remove_red_eye,
                            color: _hidePassword
                                ? Color.fromRGBO(138, 136, 136, 1)
                                : Color.fromRGBO(15, 125, 188, 1)),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      )),
                  obscureText: _hidePassword,
                ),

                SizedBox(height: showError ? 15 : 30),
                if (showError)
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                //creates the signUp button
                InkWell(
                  onTap: () async {
                    errorMessage =
                        ''; //resets the error message to an empty string
                    if (!FocusScope.of(context).hasPrimaryFocus &&
                        FocusScope.of(context).focusedChild != null) {
                      FocusScope.of(context).focusedChild.unfocus();
                    }
                    //attempts to create an account for the user with email and password. displays an error message if an error occurred
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        showError = false;
                        showLoader = true;
                      });
                      if (await _numberNotUsedByAnotherClient(number) ==
                          'notExist') {
                        dynamic result = await _auth.createAccount(
                            password: password,
                            number: '+234' + number.substring(1, 11),
                            email: email,
                            name: formatUserName(name),
                            isNumberVerified: false);

                        if (result == null)
                          setState(() {
                            showLoader = false;
                            showError = true;
                            errorMessage = _auth.error;
                          });
                        else
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Dashboard()));
                      } else if (await _numberNotUsedByAnotherClient(number) ==
                          'exists') {
                        if (mounted)
                          setState(() {
                            showLoader = false;
                            showError = true;
                            errorMessage = 'Number already used';
                          });
                      } else {
                        setState(() {
                          showLoader = false;
                          showError = true;
                          errorMessage = 'Network error';
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    color: Theme.of(context).buttonColor,
                    child: showLoader
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : Text('SignUp',
                            style: Theme.of(context).textTheme.button),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                //facebook and google sign in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        await googleSignIn(context, false);
                      },
                      child: Container(
                          height: 40, child: Image.asset('assets/google.jpg')),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                        onTap: () async {
                          await facebookLogin(context);
                        },
                        child: Container(
                          height: 40,
                          child: Image.asset('assets/facebook.jpg'),
                        )),
                  ],
                ),

                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        widget.togglePage(1);
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
              ],
            ),
          ),
        ),
        Spacer(
          flex: 4,
        ),
      ],
    );
  }
}
