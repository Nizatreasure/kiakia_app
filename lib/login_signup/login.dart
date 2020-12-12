import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiakia/login_signup/decoration2.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:email_validator/email_validator.dart';
import 'package:kiakia/login_signup/services/facebook_google_authentication.dart';
import 'package:kiakia/login_signup/services/password_reset.dart';
import 'package:localstorage/localstorage.dart';
import 'package:kiakia/screens/dashboard.dart';

class LoginPage extends StatefulWidget {
  //togglePage toggles the login and sign up  pages
  final Function togglePage;
  LoginPage(this.togglePage);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController;
  bool _hidePassword =
      true; // controls the visibility of the password a user enters
  final _formKey = GlobalKey<
      FormState>(); //controls the form used for inputting email and password
  bool showLoader = false;
  bool showError = false;
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
    _emailController = new TextEditingController();
    _emailController.addListener(() {});
    _getUserEmail();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //gets the width of the current device from mediaQuery
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Spacer(),
        Container(
          height: 70,
          alignment:
              width >= 560 ? Alignment.bottomCenter : Alignment.bottomLeft,
          child: Text(
            'Welcome,',
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
            'Securely login to Gas360',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Spacer(),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 540),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //the children were each wrapped in a constrained box to limit their sizes to a specified maximum where the width of the viewport was large
              children: [
                //creates the textField for inputting the user email

                TextFormField(
                  controller: _emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textAlignVertical: TextAlignVertical.bottom,
                  style: TextStyle(
                      height: 1.5, fontSize: 18, fontWeight: FontWeight.w500),
                  keyboardType: TextInputType.emailAddress,
                  decoration: decoration2.copyWith(hintText: 'Email address'),
                  validator: (val) {
                    return EmailValidator.validate(val.trimRight())
                        ? null
                        : 'Email is not valid';
                  },
                ),
                SizedBox(
                  height: 10,
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  toolbarOptions:
                      ToolbarOptions(copy: false, cut: false, paste: true),
                  style: TextStyle(
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: _hidePassword
                          ? Color.fromRGBO(15, 125, 188, 1)
                          : Color.fromRGBO(0, 0, 0, 1)),
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: decoration2.copyWith(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.remove_red_eye,
                          color: _hidePassword
                              ? Color.fromRGBO(179, 179, 182, 1)
                              : Color.fromRGBO(15, 125, 188, 1)),
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
                    alignment: Alignment.center,
                    height: 30,
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                InkWell(
                  onTap: () async {
                    //resets the error message to an empty string
                    errorMessage = '';
                    //this code would unFocus any textField when the button is clicked
                    if (!FocusScope.of(context).hasPrimaryFocus &&
                        FocusScope.of(context).focusedChild != null) {
                      FocusScope.of(context).focusedChild.unfocus();
                    }
                    //attempts to sign in the user if the form is validated. displays an error message if an error occured
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        showLoader = true;
                        showError = false;
                      });
                      dynamic result = await _auth.signInWithEmailAndPassword(
                          password: password, email: _emailController.text);
                      if (result == null) {
                        if (mounted)
                          setState(() {
                            showLoader = false;
                            showError = true;
                          });
                        errorMessage = _auth.error;
                      } else
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard()));
                    }
                  },
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    color: Theme.of(context).buttonColor,
                    //the container would show a loader when clicked until a response is received, then it changes back to the login text
                    child: showLoader
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : Text(
                            'Login',
                            style: Theme.of(context).textTheme.button,
                          ),
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      //displays a pop up where registered users can reset their password
                      forgotPasswordPopUp(context);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
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
                        await googleSignIn(context);
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

                //link to sign up for new users
                Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('I\'m a new user,',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16)),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(
                          onTap: () {
                            widget.togglePage(2);
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
              ],
            ),
          ),
        ),
        Spacer(
          flex: 2,
        )
      ],
    );
  }
}
