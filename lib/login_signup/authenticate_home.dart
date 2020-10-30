import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class AuthenticationHome extends StatefulWidget {
  final Function togglePage;
  AuthenticationHome(this.togglePage);

  @override
  _AuthenticationHomeState createState() => _AuthenticationHomeState();
}

class _AuthenticationHomeState extends State<AuthenticationHome> {
  PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //get the width of the screen within the context from MediaQuery
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffffffff),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
              onPageChanged: (val) {
                setState(() {
                  currentIndex = val;
                });
              },
              controller: _pageController,
              children: [
                landingPageView(
                    url: 'https://picsum.photos/200/400',
                    title: 'Easy Ordering',
                    text: 'Easing ordering of gas at your convenience'),
                landingPageView(
                    url: 'https://picsum.photos/200/450',
                    title: 'Gas is for Everyone',
                    text: 'Making gas an everybody and everyday product'),
                landingPageView(
                    url: 'https://picsum.photos/300/500',
                    title: 'Clean Energy',
                    text:
                        'Everyone can use clean energy no matter where they are'),
              ]),
          //this widget positions the buttons in the page
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,

            // the column houses the login and signUp buttons and also the pageView indicator
            child: Column(
              children: [
                //the pageView indicators are housed inside the row widget
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    indicator(currentIndex, 0),
                    SizedBox(
                      width: 5,
                    ),
                    indicator(currentIndex, 1),
                    SizedBox(
                      width: 5,
                    ),
                    indicator(currentIndex, 2),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                // this container displays the signUp button and is wrapped with InkWell to make it clickable
                InkWell(
                  onTap: () {
                    widget.togglePage(3);
                  },
                  child: Container(
                    width: width,
                    height: 50,
                    alignment: Alignment.center,
                    margin: width > 500
                        ? EdgeInsets.symmetric(horizontal: 50, vertical: 10)
                        : EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                    widget.togglePage(2);
                  },
                  child: Container(
                    width: width,
                    height: 50,
                    alignment: Alignment.center,
                    margin: width > 500
                        ? EdgeInsets.symmetric(horizontal: 50, vertical: 10)
                        : EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Color.fromRGBO(77, 172, 246, 1), width: 2)),
                    child: Text(
                      'Log In',
                      style: TextStyle(
                          color: Color.fromRGBO(77, 172, 246, 1),
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//creates the sliding display at the app landing page
Widget landingPageView(
    {@required String url, @required String title, @required String text}) {
  return Stack(
    children: [
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
              ),
              SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.red,
          gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0), Colors.grey[900]],
              stops: [0, 0.6]),
        ),
      ),
    ],
  );
}

//constructs the pageView indicator
Widget indicator(int currentIndex, int pageIndex) {
  return Container(
    height: 10,
    width: 10,
    decoration: BoxDecoration(
        color: currentIndex == pageIndex ? Colors.white : Colors.white30,
        borderRadius: BorderRadius.circular(10)),
  );
}
