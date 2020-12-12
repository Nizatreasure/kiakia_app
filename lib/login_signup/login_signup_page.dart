import 'package:flutter/material.dart';
import 'package:kiakia/login_signup/login.dart';
import 'package:kiakia/login_signup/signup.dart';

class LoginSignUpPage extends StatefulWidget {
  final Function togglePage;
  LoginSignUpPage(this.togglePage);
  @override
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  int pageId;
  changePageId(int id) {
    setState(() {
      pageId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: LayoutBuilder(
            builder: (context, viewConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: viewConstraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  pageId = 1;
                                });
                              },
                              child: Container(
                                height: 30,
                                alignment: Alignment(0, 0.2),
                                decoration: pageId != 2
                                    ? BoxDecoration(
                                        border: BorderDirectional(
                                          bottom: BorderSide(
                                              color: Color.fromRGBO(
                                                  81, 83, 82, 0.75),
                                              width: 2),
                                        ),
                                      )
                                    : null,
                                child: Text(
                                  'Login',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(fontSize: 20),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  pageId = 2;
                                });
                              },
                              child: Container(
                                height: 30,
                                alignment: Alignment(0, 0.2),
                                decoration: pageId == 2
                                    ? BoxDecoration(
                                        border: BorderDirectional(
                                          bottom: BorderSide(
                                              color: Color.fromRGBO(
                                                  81, 83, 82, 0.75),
                                              width: 2),
                                        ),
                                      )
                                    : null,
                                child: Text(
                                  'Sign Up',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                            child: pageId == 2
                                ? SignUp(changePageId)
                                : LoginPage(changePageId)),
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
