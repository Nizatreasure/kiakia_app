import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiakia/login_signup/decoration.dart';
import 'package:kiakia/screens/order_screen/order_details.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Order extends StatefulWidget {
  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String selectedValue; //used for the dropdown menu
  bool _disableIncreaseGasSizeButton = false;
  bool _disableDecreaseGasSizeButton = true;
  int gasSize = 2;


  //controls the selection of one size among the available sizes of cylinders
  Map<int, bool> cylinderSize = {
    1: false,
    2: false,
    3: false,
    4: false,
  };

  //removes the selection from all/any selected cylinder
  void changeCylinderSize() {
    setState(() {
      for (int i = 1; i < 5; i++) {
        cylinderSize[i] = false;
      }
    });
  }

  List paymentMode = [
    'Bank Transfer',
    'Credit Card',
    'Ewallet',
    'Direct Deposit'
  ];


  //increases the size of the gas cylinder
  void incrementGasSize() {
    setState(() {
      if (gasSize < 20) {
        _disableIncreaseGasSizeButton = false;
        _disableDecreaseGasSizeButton = false;
        gasSize += 1;
        if (gasSize != 2 && gasSize != 8 && gasSize != 15) {
          changeCylinderSize();
        } // removes selection from the cylinder size container when the increase or decrease button is pressed
      }
      if (gasSize == 20) _disableIncreaseGasSizeButton = true;
    });
  }

  //decreases the size of the gas cylinder
  void decrementGasSize() {
    setState(() {
      if (gasSize > 2) {
        _disableDecreaseGasSizeButton = false;
        _disableIncreaseGasSizeButton = false;
        gasSize -= 1;
        if (gasSize != 8 && gasSize != 15 && gasSize != 20) {
          changeCylinderSize();
        } // removes selection from the cylinder size container when the increase or decrease button is pressed
      }
      if (gasSize == 2) _disableDecreaseGasSizeButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gasSize == 2) cylinderSize[1] = true;
    if (gasSize == 8) cylinderSize[2] = true;
    if (gasSize == 15) cylinderSize[3] = true;
    if (gasSize == 20) cylinderSize[4] = true;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Stack(
            alignment: Alignment(0, 0.85),
            children: [
              Container(
                height: 200,
                child: Center(
                  child: SfRadialGauge(
                    axes: [
                      RadialAxis(
                        maximum: 100,
                        minimum: 0,
                        showTicks: false,
                        showLabels: false,
                        startAngle: 128,
                        endAngle: 52,
                        axisLineStyle: AxisLineStyle(
                          thicknessUnit: GaugeSizeUnit.factor,
                          thickness: 0.2,
                          cornerStyle: CornerStyle.bothCurve,
                          color: Color.fromRGBO(77, 172, 246, 0.4),
                        ),
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Container(
                              height: 70,
                              width: 80,
                              child: Image.asset('assets/gas_cylinder.jpg'),
                            ),
                            angle: 90,
                            positionFactor: 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 245, 250, 1),
                      borderRadius: BorderRadius.circular(20)),
                  width: 105,
                  height: 30,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      IconButton(
                          splashRadius: 25,
                          constraints: BoxConstraints.tight(Size(35, 30)),
                          icon: Icon(
                            Icons.remove,
                            size: 14,
                            color: _disableDecreaseGasSizeButton
                                ? Color.fromRGBO(196, 196, 196, 1)
                                : Color.fromRGBO(0, 0, 0, 1),
                          ),
                          onPressed: _disableDecreaseGasSizeButton
                              ? null
                              : decrementGasSize),
                      Text(
                        '$gasSize kg',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontWeight: FontWeight.w500),
                      ),
                      IconButton(
                          splashRadius: 25,
                          constraints: BoxConstraints.tight(Size(35, 30)),
                          icon: Icon(
                            Icons.add,
                            size: 14,
                            color: _disableIncreaseGasSizeButton
                                ? Color.fromRGBO(196, 196, 196, 1)
                                : Color.fromRGBO(0, 0, 0, 1),
                          ),
                          onPressed: _disableIncreaseGasSizeButton
                              ? null
                              : incrementGasSize)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, bottom: 20),
          child: Text('Cylinder Size',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  changeCylinderSize();
                  cylinderSize[1] = true;
                  gasSize = 2;
                  _disableIncreaseGasSizeButton = false;
                  _disableDecreaseGasSizeButton = true;
                  setState(() {});
                },
                child: CylinderSize(
                  text: 'S',
                  value: cylinderSize[1],
                ),
              ),
              InkWell(
                onTap: () {
                  changeCylinderSize();
                  cylinderSize[2] = true;
                  gasSize = 8;
                  _disableIncreaseGasSizeButton = false;
                  _disableDecreaseGasSizeButton = false;
                  setState(() {});
                },
                child: CylinderSize(
                  text: 'M',
                  value: cylinderSize[2],
                ),
              ),
              InkWell(
                onTap: () {
                  changeCylinderSize();
                  cylinderSize[3] = true;
                  gasSize = 15;
                  _disableIncreaseGasSizeButton = false;
                  _disableDecreaseGasSizeButton = false;
                  setState(() {});
                },
                child: CylinderSize(
                  text: 'L',
                  value: cylinderSize[3],
                ),
              ),
              InkWell(
                onTap: () {
                  changeCylinderSize();
                  cylinderSize[4] = true;
                  gasSize = 20;
_disableIncreaseGasSizeButton = true;
                  _disableDecreaseGasSizeButton = false;
                  setState(() {});
                },
                child: CylinderSize(
                  text: 'XL',
                  value: cylinderSize[4],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 20, bottom: 20),
          child: Text(
            'Location',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: TextField(
            style: TextStyle(fontSize: 20),
            decoration: decoration.copyWith(
                hintText: 'Enter location',
                hintStyle: TextStyle(
                  fontSize: 22,
                ),
                suffixIcon: Icon(
                  Icons.location_on,
                  color: Color.fromRGBO(179, 179, 182, 1),
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 20, bottom: 20),
          child: Text(
            'Payment Mode',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: DropdownButtonFormField(
            icon: Icon(
              Icons.arrow_drop_down,
              size: 28,
              color: Color.fromRGBO(179, 179, 182, 1),
            ),
            style: TextStyle(fontSize: 20, color: Colors.black),
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            decoration: decoration.copyWith(hintText: 'Select Payment Method'),
            items: paymentMode.map((item) {
              return DropdownMenuItem(
                child: Text(item),
                value: item,
              );
            }).toList(),
            value: selectedValue,
            onChanged: (val) {
              selectedValue = val;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
          child: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OrderDetails()));
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromRGBO(77, 172, 246, 1)),
              child: Text(
                'Order Details',
                style: TextStyle(
                    color: Color.fromRGBO(246, 248, 250, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CylinderSize extends StatelessWidget {
  final String text;
  final bool value;

  CylinderSize({
    this.value,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: value
              ? Color.fromRGBO(15, 125, 188, 1)
              : Color.fromRGBO(77, 172, 246, 1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: value ? 30 : 26,
            color: Color.fromRGBO(255, 255, 255, 1)),
      ),
    );
  }
}
