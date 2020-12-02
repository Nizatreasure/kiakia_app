import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:provider/provider.dart';

class OrderReceived extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffffffff),
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Color(0xffffffff),
        body: LayoutBuilder(
          builder: (context, viewportConstraint) {
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: viewportConstraint.maxHeight, maxWidth: 500),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            constraints: BoxConstraints(minHeight: 200),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/landing_page1.jpg',
                            ),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .color),
                                children: [
                                  TextSpan(
                                    text: 'Order Received\n',
                                  ),
                                  TextSpan(
                                      text:
                                          'You can monitor and track your delivery on your dashboard. Thank you for choosing us',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400))
                                ]),
                          ),
                        )),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Provider.of<ChangeButtonNavigationBarIndex>(context,
                                    listen: false)
                                .updateCurrentIndex(0);
                          },
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            color: Theme.of(context).buttonColor,
                            child: Text(
                              'Done',
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(fontSize: 20),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
