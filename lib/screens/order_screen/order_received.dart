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
                          child: Container(
                            color: Colors.white,
                            child: Image.asset('assets/received.jpg',),

                          ),),
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
