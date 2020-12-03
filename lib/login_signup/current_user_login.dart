import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kiakia/login_signup/decoration2.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:kiakia/login_signup/services/facebook_google_authentication.dart';
import 'package:kiakia/login_signup/services/password_reset.dart';
import 'package:local_auth/local_auth.dart';

class CurrentUserLoginPage extends StatefulWidget {
  final Function togglePage;
  final Map data;
  CurrentUserLoginPage({this.togglePage, this.data});
  @override
  _CurrentUserLoginPageState createState() => _CurrentUserLoginPageState();
}

class _CurrentUserLoginPageState extends State<CurrentUserLoginPage> {
  ScrollController _scrollController;
  bool _hidePassword =
      true; // controls the visibility of the password a user enters
  final _formKey = GlobalKey<
      FormState>(); //controls the form used for inputting email and password
  bool showLoader = false;
  bool showError = false;
  FocusNode _passwordFocusNode;
  AuthenticationService _auth = AuthenticationService();
  String password = '', errorMessage = '', pass;
  final secureStorage = new FlutterSecureStorage();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool authenticating = false;
  bool _biometricsAvailable = false;

  //checks if any hardware biometrics is available
  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
      setState(() {
        _biometricsAvailable = isAvailable;
      });
      return isAvailable;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

//gets the list of all available biometrics
  Future<void> _getListOfAvailableBiometrics() async {
    try {
      await _localAuthentication.getAvailableBiometrics();
      print(await _localAuthentication.getAvailableBiometrics());
      if (!mounted) return;
    } on PlatformException catch (e) {
      print(e);
    }
  }

  //authenticates the user using biometrics
  Future _authenticateUser(email, pass) async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to log in',
          stickyAuth: true,
          useErrorDialogs: true);
      setState(() {});
      if (isAuthenticated) {
        setState(() {
          authenticating = true;
          showLoader = true;
          showError = false;
        });
        dynamic result = await _auth.signInWithEmailAndPassword(
            email: email, password: pass);
        if (result == null) {
          setState(() {
            authenticating = false;
            showError = true;
            showLoader = false;
          });
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text('An error occurred, please try again'),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    )
                  ],
                );
              });
        }
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  _readFromSecureStorage() async {
    final word = await secureStorage.read(key: 'password');
    setState(() {
      pass = word;
    });
  }

  @override
  void initState() {
    super.initState();
    _isBiometricAvailable();
    _passwordFocusNode = FocusNode();
    _passwordFocusNode.addListener(() {
      //hides the password when a user focus changes from the password field
      if (!_passwordFocusNode.hasFocus) {
        _hidePassword = true;
      }
    });
    _scrollController = new ScrollController();
    _scrollController.addListener(() {});
    _readFromSecureStorage();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _passwordFocusNode.dispose();
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
                            height: 100,
                            alignment: width >= 560 ||
                                    widget.data['provider'] == 'google' ||
                                    widget.data['provider'] == 'facebook'
                                ? Alignment.center
                                : Alignment.centerLeft,
                            child: RichText(
                              textAlign: width >= 560 ||
                                      widget.data['provider'] == 'google' ||
                                      widget.data['provider'] == 'facebook'
                                  ? TextAlign.center
                                  : TextAlign.left,
                              text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w500),
                                  children: [
                                    TextSpan(
                                        text: width > 560
                                            ? 'Welcome back '
                                            : 'Welcome back ',),
                                    TextSpan(
                                        text: widget.data['name'].toString().split(' ')[0],
                                        style: TextStyle(
                                            fontSize: 32,
                                            color: Color.fromRGBO(
                                                57, 138, 239, 1)))
                                  ]),
                            ),
                          ),
                          Container(
                            height: 50,
                            alignment: width >= 560 ||
                                    widget.data['provider'] == 'google' ||
                                    widget.data['provider'] == 'facebook'
                                ? Alignment.center
                                : Alignment.centerLeft,
                            child: Text(
                              'Securely login to Gas360',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20),
                            ),
                          ),
                          Spacer(),
                          if (widget.data['provider'] == 'email' ||
                              widget.data['provider'] == null ||
                              widget.data['provider'] == '')
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 500),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  //the children were each wrapped in a constrained box to limit their sizes to a specified maximum where the width of the viewport was large
                                  children: [
                                    //creates the textField for inputting the user password
                                    TextFormField(
                                      onChanged: (val) {
                                        password = val;
                                      },
                                      validator: (val) {
                                        if (val.trim().isEmpty)
                                          return 'Password cannot be empty';
                                        return null;
                                      },
                                      focusNode: _passwordFocusNode,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      toolbarOptions: ToolbarOptions(
                                          copy: false, cut: false, paste: true),
                                      style: TextStyle(
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: _hidePassword
                                              ? Color.fromRGBO(15, 125, 188, 1)
                                              : Color.fromRGBO(0, 0, 0, 1)),
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      decoration: decoration2.copyWith(
                                        hintText: 'Password',
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.remove_red_eye,
                                              color: _hidePassword
                                                  ? Color.fromRGBO(
                                                      179, 179, 182, 1)
                                                  : Color.fromRGBO(
                                                      15, 125, 188, 1)),
                                          onPressed: () {
                                            setState(() {
                                              _hidePassword = !_hidePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: _hidePassword,
                                    ),

                                    SizedBox(
                                      height: showError ? 15 : 30,
                                    ),
                                    if (showError)
                                      Container(
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: Text(
                                          errorMessage,
                                          style: TextStyle(color: Colors.red),
                                        ),
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
                                        //attempts to sign in the user if the form is validated. displays an error message if an error occurred
                                        if (_formKey.currentState.validate()) {
                                          setState(() {
                                            showError = false;
                                            showLoader = true;
                                            _scrollController.jumpTo(
                                                _scrollController
                                                    .position.maxScrollExtent);
                                          });
                                          dynamic result = await _auth
                                              .signInWithEmailAndPassword(
                                                  password: password,
                                                  email: widget.data['email']);
                                          if (result == null) {
                                            if (mounted)
                                              setState(() {
                                                showLoader = false;
                                                showError = true;
                                              });
                                            errorMessage = _auth.error;
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        color: Color.fromRGBO(15, 125, 188, 1),
                                        child: showLoader
                                            ? CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white),
                                              )
                                            : Text(
                                                'Login',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        246, 248, 250, 1),
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                      ),
                                    ),
                                    SizedBox(height: 7),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onTap: () {
                                          //displays a pop up where registered users can reset their password
                                          forgotPasswordPopUp(context);
                                        },
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 15),
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      height: 20,
                                    ),

                                    //displays a button where the users can click to log in with fingerprint
                                    if (_biometricsAvailable)
                                      Center(
                                          child: IconButton(
                                              color: Colors.blue,
                                              onPressed: authenticating
                                                  ? null
                                                  : () async {
                                                      if (await _isBiometricAvailable()) {
                                                        await _getListOfAvailableBiometrics();
                                                        if (pass != null)
                                                          await _authenticateUser(
                                                              widget.data[
                                                                  'email'],
                                                              pass);
                                                      }
                                                    },
                                              icon: Icon(
                                                Icons.fingerprint,
                                                size: 45,
                                              ))),
                                  ],
                                ),
                              ),
                            ),

                          //this row holds the login buttons for google and facebook
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.data['provider'] == 'google')
                                InkWell(
                                    onTap: () async {
                                      await googleSignIn(context);
                                    },
                                    splashColor: Colors.transparent,
                                    child: Container(
                                      height: 60,
                                      child: Row(
                                        children: [
                                          Image.asset('assets/google.jpg'),
                                          Container(
                                            alignment: Alignment(0, 0.3),
                                            child: Text(
                                              'oogle',
                                              style: TextStyle(fontSize: 22),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              if (widget.data['provider'] == 'facebook')
                                InkWell(
                                  onTap: () async {
                                    await facebookLogin(context);
                                  },
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    height: 60,
                                    child: Row(
                                      children: [
                                        Image.asset('assets/facebook.jpg'),
                                        Container(
                                            alignment: Alignment(0, 0.5),
                                            child: Text('acebook',
                                                style: TextStyle(fontSize: 22)))
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 40,
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () async {
                                widget.togglePage(2);
                                await GoogleSignIn().signOut();
                                await FacebookLogin().logOut();
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'No, I am not ${widget.data['name'].toString().split(' ')[0]}',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          Spacer(
                            flex: 3,
                          ),
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
