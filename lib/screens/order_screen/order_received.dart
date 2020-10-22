import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiakia/screens/order_screen/track_rider.dart';

class OrderReceived extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffffffff),
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
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: Color(0xffffffff),
        body: LayoutBuilder(
          builder: (context, viewportConstraint) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Spacer(),
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/gas_cylinder2.jpg',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10,
                        ),
                        child: Text(
                          'Order Received',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 90,
                        child: Image.asset('assets/logo.jpg'),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TrackRider()));
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromRGBO(77, 172, 246, 1)),
                          child: Text(
                            'Track Cylinder',
                            style: TextStyle(
                                color: Color.fromRGBO(246, 248, 250, 1),
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
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
            );
          },
        ));
  }
}
