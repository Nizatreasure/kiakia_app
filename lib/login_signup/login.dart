import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kiakia/login_signup/decoration.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:email_validator/email_validator.dart';

class LoginPage extends StatefulWidget {
  final Function togglePage;
  LoginPage(this.togglePage);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ScrollController _scrollController;
  bool _hidePassword =
      true; // controls the visibility of the password a user enters
  final _formKey = GlobalKey<
      FormState>(); //controls the form used for inputting email and password
  bool showLoader = false;
  bool showLoaderAndError = false;
  FocusNode _passwordFocusNode;
  AuthenticationService _auth = AuthenticationService();
  String email = '', password = '', errorMessage = '';

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
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
//      appBar: AppBar(
//        backgroundColor: Colors.white,
//        leading: IconButton(
//          icon: Icon(
//            Icons.keyboard_arrow_left,
//            color: Colors.black,
//            size: 30,
//          ),
//          onPressed: () {
//            Navigator.pop(context);
//          },
//        ),
//        elevation: 0,
//      ),
      body: SafeArea(
        child: Padding(
            padding: width > 500
                ? EdgeInsets.symmetric(horizontal: 50.0)
                : EdgeInsets.symmetric(horizontal: 30.0),
            child: LayoutBuilder(
              builder: (context, viewportConstraint) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: viewportConstraint.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Container(
                            height: 70,
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Color.fromRGBO(15, 125, 188, 1),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            height: 50,
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Welcome back',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromRGBO(220, 221, 225, 1)),
                            ),
                          ),
                          Spacer(),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //creates the textField for inputting the user email
                                TextFormField(
                                  onChanged: (val) {
                                    email = val;
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: decoration.copyWith(
                                      labelText: 'Email',
                                      hintText: 'Enter your email address'),
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
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: decoration.copyWith(
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
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
                                      )),
                                  obscureText: _hidePassword,
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      forgotPasswordPopUp(context);
                                    },
                                    child: Text('Forgot Password?',
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 14)),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                InkWell(
                                  onTap: () async {
                                    errorMessage =
                                        ''; //resets the error message to an empty string
                                    if (!FocusScope.of(context)
                                            .hasPrimaryFocus && //this code would unFocus any textField when the button is clicked
                                        FocusScope.of(context).focusedChild !=
                                            null) {
                                      FocusScope.of(context)
                                          .focusedChild
                                          .unfocus();
                                    }

                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        showLoaderAndError = true;
                                        showLoader = true;
                                      });
                                      dynamic result = await _auth
                                          .signInWithEmailAndPassword(
                                              password: password, email: email);
                                      setState(() {
                                        showLoader = false;
                                      });
                                      if (result == null) {
                                        errorMessage = _auth.error;
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
                                      'Login',
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
                          SizedBox(
                            height: 17,
                          ),
                          Container(
                            height: 40,
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No account?'),
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

  //builds the dialog box for resetting password
  forgotPasswordPopUp(BuildContext myContext) {
    final _resetFormKey = GlobalKey<FormState>();
    String resetEmail, resetError  = '';
    bool showLoaderAndResetError = false, showResetLoader = false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        child: StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Enter your email address: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                      decoration:
                          decoration.copyWith(hintText: 'Email address'),
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
                      autofocus: true,
                    ),
                  ),
                ),
                showLoaderAndResetError
                    ? Center(
                  child: showResetLoader
                      ? Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CircularProgressIndicator(),
                  )
                      : Text(
                    resetError, textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red,),
                  ),
                )
                    : Text(''),
                Row(
                  children: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        )),
                    Spacer(),
                    FlatButton(
                        textColor: Colors.blue,
                        onPressed: () async {
                          if (_resetFormKey.currentState.validate()) {
                            setState(() {
                              showLoaderAndResetError = true;
                              showResetLoader = true;
                            });
                             dynamic result = await _auth.resetUserPassword(resetEmail);
                            setState(() {
                              showResetLoader = false;
                            });
                             if (result == null) {
                               setState(() {
                                 resetError = _auth.error;
                               });
                             }
                             else {
                               Navigator.pop(context);
                               successfulPasswordResetMail(email: resetEmail, context: myContext);
                             }
                          }

                        },
                        child: Text(
                          'Reset password',
                          style: TextStyle(fontSize: 16),
                        )),
                  ],
                )
              ],
            ),
          );
        }));
  }
  successfulPasswordResetMail({String email, BuildContext context}) {
    return showDialog(context: context,
    barrierDismissible: false,
    child: AlertDialog(
      content: RichText(text: TextSpan(style: TextStyle(fontSize: 16, color: Colors.black), children: [
        TextSpan(text: 'A password reset mail has been sent to '),
        TextSpan(text: email, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      ]),),
      actions: [
        FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text('OK', style: TextStyle(fontSize: 17),))
      ],
    ));
  }
}