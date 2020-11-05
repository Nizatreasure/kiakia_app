import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kiakia/login_signup/decoration.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:email_validator/email_validator.dart';
import 'package:kiakia/login_signup/services/facebook_google_authentication.dart';
import 'package:kiakia/login_signup/services/password_reset.dart';
import 'package:localstorage/localstorage.dart';

class LoginPage extends StatefulWidget {
  final Function togglePage;
  LoginPage(this.togglePage);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController;
  TextEditingController _numberController;
  ScrollController _scrollController;
  bool _hidePassword =
      true; // controls the visibility of the password a user enters
  final _formKey = GlobalKey<
      FormState>(); //controls the form used for inputting email and password
  bool showLoader = false;
  bool showLoaderAndError = false;
  FocusNode _passwordFocusNode;
  AuthenticationService _auth = AuthenticationService();
  String password = '', errorMessage = '';
  final storage = new LocalStorage('user_data.json');
  int id = 1;

  _getUserEmail() async {
    Map data = storage.getItem('userData');
    if (data != null && data['email'] != null) {
      _emailController.text = data['email'];
    }
  }

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
    _emailController = new TextEditingController();
    _emailController.addListener(() {});
    _numberController = new TextEditingController();
    _numberController.addListener(() {});
    _getUserEmail();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //gets the width of the current device from mediaQuery
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: LayoutBuilder(
              builder: (context, viewportConstraint) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: viewportConstraint.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: width >= 560
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Container(
                            height: 70,
                            alignment: width >= 560
                                ? Alignment.bottomCenter
                                : Alignment.bottomLeft,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Theme.of(context).buttonColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            height: 50,
                            alignment: width >= 560
                                ? Alignment.topCenter
                                : Alignment.topLeft,
                            child: Text(
                              'Welcome back',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromRGBO(220, 221, 225, 1)),
                            ),
                          ),
                          Spacer(),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 540),
                            child: Card(
                              color: Colors.black45,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    //the children were each wrapped in a constrained box to limit their sizes to a specified maximum where the width of the viewport was large
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                id = 1;
                                              });
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 30,
                                                    vertical: 10),
                                                color: id == 1
                                                    ? Theme.of(context).buttonColor
                                                    : Colors.transparent,
                                                child: Text(
                                                  'Email',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          id == 1 ? 18 : 16),
                                                )),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                id = 2;
                                              });
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 30,
                                                    vertical: 10),
                                                color: id == 2
                                                    ? Theme.of(context).buttonColor
                                                    : Colors.transparent,
                                                child: Text(
                                                  'Number',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          id == 2 ? 18 : 16),
                                                )),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      //creates the textField for inputting the user email
                                      if (id == 1)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              controller: _emailController,
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              textAlignVertical:
                                                  TextAlignVertical.bottom,
                                              style: TextStyle(
                                                  height: 1.5,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: decoration.copyWith(
                                                  labelText: 'Email',
                                                  hintText:
                                                      'Enter your email address'),
                                              validator: (val) {
                                                return EmailValidator.validate(
                                                        val.trimRight())
                                                    ? null
                                                    : 'Email is not valid';
                                              },
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            //creates the textField for inputting the user password
                                            TextFormField(
                                              onChanged: (val) {
                                                password = val;
                                              },
                                              validator: (val) {
                                                if (val.trim().isEmpty)
                                                  return 'Password cannot be empty';
                                                else
                                                  return null;
                                              },
                                              focusNode: _passwordFocusNode,
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              toolbarOptions: ToolbarOptions(
                                                  copy: false,
                                                  cut: false,
                                                  paste: true),
                                              style: TextStyle(
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: _hidePassword
                                                      ? Color.fromRGBO(
                                                          15, 125, 188, 1)
                                                      : Color.fromRGBO(
                                                          0, 0, 0, 1)),
                                              textAlignVertical:
                                                  TextAlignVertical.bottom,
                                              decoration: decoration.copyWith(
                                                labelText: 'Password',
                                                hintText: 'Enter your password',
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                      Icons.remove_red_eye,
                                                      color: _hidePassword
                                                          ? Color.fromRGBO(
                                                              179, 179, 182, 1)
                                                          : Color.fromRGBO(
                                                              15, 125, 188, 1)),
                                                  onPressed: () {
                                                    setState(() {
                                                      _hidePassword =
                                                          !_hidePassword;
                                                    });
                                                  },
                                                ),
                                              ),
                                              obscureText: _hidePassword,
                                            ),
                                            SizedBox(
                                              height: 7,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: InkWell(
                                                onTap: () {
                                                  //displays a pop up where registered users can reset their password
                                                  forgotPasswordPopUp(context);
                                                },
                                                child: Text(
                                                  'Forgot Password?',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (id == 2)
                                        TextFormField(
                                          controller: _numberController,
                                          onChanged: (val) {
                                            if (val.length == 11) {
                                              FocusScope.of(context)
                                                  .focusedChild
                                                  .unfocus();
                                            }
                                          },
                                          maxLength: 11,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          textAlignVertical:
                                              TextAlignVertical.bottom,
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
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(11)
                                          ], //makes the textField receive only digits
                                          decoration: decoration.copyWith(
                                              labelText: 'Phone Number',
                                              hintText:
                                                  'Enter your phone number',
                                              counterText: ''),
                                        ),
                                      SizedBox(
                                        height: 40,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          //resets the error message to an empty string
                                          errorMessage = '';
                                          //this code would unFocus any textField when the button is clicked
                                          if (!FocusScope.of(context)
                                                  .hasPrimaryFocus &&
                                              FocusScope.of(context)
                                                      .focusedChild !=
                                                  null) {
                                            FocusScope.of(context)
                                                .focusedChild
                                                .unfocus();
                                          }
                                          //attempts to sign in the user if the form is validated. displays an error message if an error occured
                                          if (_formKey.currentState
                                              .validate()) {
                                            setState(() {
                                              showLoaderAndError = true;
                                              showLoader = true;
                                              _scrollController.jumpTo(
                                                  _scrollController.position
                                                      .maxScrollExtent);
                                            });
                                            if (id == 1) {
                                              dynamic result = await _auth
                                                  .signInWithEmailAndPassword(
                                                      password: password,
                                                      email: _emailController
                                                          .text);
                                              if (result == null) {
                                                if (mounted)
                                                  setState(() {
                                                    showLoader = false;
                                                  });
                                                errorMessage = _auth.error;
                                              }
                                            } else {
                                              if (await checkUser(
                                                      _numberController.text) ==
                                                  'notExist') {
                                                if (mounted)
                                                  setState(() {
                                                    showLoader = false;
                                                    errorMessage =
                                                        'Number does not exist. Kindly register';
                                                  });
                                              } else if (await checkUser(
                                                      _numberController.text) ==
                                                  'notVerified') {
                                                if (mounted)
                                                  setState(() {
                                                    showLoader = false;
                                                    errorMessage =
                                                        'Number not verified. Please log in with corresponding provider to verify number';
                                                  });
                                              } else if (await checkUser(
                                                      _numberController.text) ==
                                                  'verified') {
                                                await _auth.verifyNumber(
                                                    number: '+234' +
                                                        _numberController.text
                                                            .substring(1, 11),
                                                    myContext: context,
                                                    id: 1);
                                                setState(() {
                                                  showLoader = false;
                                                });
                                              } else if (mounted)
                                                setState(() {
                                                  showLoader = false;
                                                  errorMessage =
                                                      'An error occurred';
                                                });
                                            }
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Theme.of(context).buttonColor),
                                          child: Text(
                                            'Login',
                                            style: Theme.of(context).textTheme.button,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ),
                                )
                              : Text(''),
                          SizedBox(
                            height: 17,
                          ),
                          Container(
                            height: 40,
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No account?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                    onTap: () {
                                      widget.togglePage(3);
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ],
                            ),
                          ),
                          Spacer(
                            flex: 3,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                  color: Colors.yellow,
                                  onPressed: () async {
                                    await googleSignIn(context);
                                  },
                                  child: Text(
                                    'Google',
                                    style: TextStyle(fontSize: 20),
                                  )),
                              SizedBox(
                                width: 20,
                              ),
                              FlatButton(
                                  color: Colors.blue,
                                  onPressed: () async {
                                    await facebookLogin(context);
                                  },
                                  child: Text(
                                    'Facebook',
                                    style: TextStyle(fontSize: 20),
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }
}

Future<String> checkUser(String number) async {
  String key;
  DataSnapshot snapshot =
      await FirebaseDatabase.instance.reference().child('users').once();
  Map data = snapshot.value;
  data.forEach((k, v) {
    if (v['number'] == '+234' + number.substring(1, 11)) key = k;
  });
  if (key == null)
    return 'notExist';
  else if (data[key]['isNumberVerified'] == false)
    return 'notVerified';
  else
    return 'verified';
}
