import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AuthenticationHome extends StatelessWidget {
  final Function togglePage;
  AuthenticationHome(this.togglePage);
  @override
  Widget build(BuildContext context) {
    //get the width of the screen within the context from MediaQuery
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffffffff),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, viewportConstraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraint.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Spacer(
                      flex: 5,
                    ),

                    //this container holds the logo
                    Container(
                      width: width > 500 ? 400 : width * 0.7,
                      child: Image.asset('assets/logo.jpg'),
                    ),

                    Spacer(
                      flex: 3,
                    ),

                    // this container displays the signUp button and is wrapped with InkWell to make it clickable
                    InkWell(
                      onTap: () {
                        togglePage(2);
                      },
                      child: Container(
                        width: width,
                        height: 50,
                        alignment: Alignment.center,
                        margin: width > 500
                            ? EdgeInsets.symmetric(horizontal: 50, vertical: 10)
                            : EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromRGBO(15, 125, 188, 1)),
                        child: Text(
                          'SignUp',
                          style: TextStyle(
                              color: Color.fromRGBO(246, 248, 250, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    // this container displays the login button and is wrapped with InkWell to make it clickable
                    InkWell(
                      onTap: () {
                        togglePage(1);
                      },
                      child: Container(
                        width: width,
                        height: 50,
                        alignment: Alignment.center,
                        margin: width > 500
                            ? EdgeInsets.symmetric(horizontal: 50, vertical: 10)
                            : EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Color.fromRGBO(77, 172, 246, 1),
                                width: 2)),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                              color: Color.fromRGBO(77, 172, 246, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
