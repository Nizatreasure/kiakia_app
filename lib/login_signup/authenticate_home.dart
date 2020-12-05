import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AuthenticationHome extends StatefulWidget {
  final Function togglePage;
  AuthenticationHome(this.togglePage);

  @override
  _AuthenticationHomeState createState() => _AuthenticationHomeState();
}

class _AuthenticationHomeState extends State<AuthenticationHome> {
  int currentIndex = 1;

  toggleLandingPage(int page) {
    setState(() {
      currentIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex == 2)
      return landingPageView(
          url: 'assets/landing_page2.jpg',
          title: 'Gas is for Everyone',
          text: 'Making gas an everybody and everyday product',
          value: 0.66,
          goToLogin: widget.togglePage,
          toggleLandingPage: toggleLandingPage,
          currentIndex: currentIndex);
    if (currentIndex == 3)
      return landingPageView(
          url: 'assets/landing_page2.jpg',
          title: 'Clean Energy',
          text: 'Everyone can use clean energy no matter where they are',
          value: 1,
          goToLogin: widget.togglePage,
          toggleLandingPage: toggleLandingPage,
          currentIndex: currentIndex);
    return landingPageView(
        url: 'assets/landing_page1.jpg',
        title: 'Easy Ordering',
        text: 'Easing ordering of gas at your convenience',
        value: 0.33,
        goToLogin: widget.togglePage,
        toggleLandingPage: toggleLandingPage,
        currentIndex: currentIndex);
  }
}

//creates the three images shown on the landing page
Widget landingPageView(
    {@required String url,
    @required String title,
    @required String text,
    @required double value,
    @required Function toggleLandingPage,
    @required Function goToLogin,
    @required currentIndex}) {
  return Scaffold(
    backgroundColor: Color(0xffffffff),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(builder: (context, viewConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewConstraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () {
                          goToLogin(2);
                        },
                        splashColor: Colors.transparent,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                              color: Color.fromRGBO(81, 83, 82, 1),
                              fontWeight: FontWeight.w400,
                              fontSize: 24),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        alignment: Alignment(0, 0.6),
                        child: Image.asset(url),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: TextStyle(
                                color: Color.fromRGBO(57, 138, 239, 1),
                                fontSize: 24,
                                fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(text: '$title\n'),
                              TextSpan(
                                  text: text,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16))
                            ]),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 74,
                          width: 74,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            value: value,
                            valueColor: AlwaysStoppedAnimation(
                                Color.fromRGBO(57, 138, 239, 1)),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            if (currentIndex < 3)
                              toggleLandingPage(currentIndex + 1);
                            else
                              goToLogin(2);
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(57, 138, 239, 1),
                                shape: BoxShape.circle),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}
