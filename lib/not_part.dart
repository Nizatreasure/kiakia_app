import 'dart:math';
import 'package:flutter/material.dart';

class NotPart extends StatefulWidget {
  @override
  _NotPartState createState() => _NotPartState();
}

class _NotPartState extends State<NotPart> with TickerProviderStateMixin {
  double size = 10;
  Animation animation;
  AnimationController _controller;
  Tween _rotationTween = Tween(begin: -pi, end: pi);

  Animation animation2;
  AnimationController _controller2;
  Tween _rotationTween2 = ColorTween(begin: Colors.blue, end: Colors.red);

  Animation animation3;
  AnimationController _controller3;
  Tween _rotationTween3 = Tween(begin: 0, end: 0.4);

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    animation = _rotationTween.animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat();
        }
      });

    _controller.forward();

    _controller2 =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    animation2 = _rotationTween2.animate(_controller2)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller2.repeat(
            reverse: true,
          );
        }
      });

    _controller2.forward();

    _controller3 =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    animation3 = _rotationTween3.animate(_controller3)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          _controller3.repeat(reverse: true);
      });

    _controller3.forward();
  }

  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 1, right: 1, top: 1),
              color: Colors.yellow,
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: CustomPaint(
                painter: MyPainter(
                    sides: 5,
                    radius: size,
                    rad: animation.value,
                    val: double.parse(animation3.value.toStringAsFixed(2)),
                    color: animation2.value),
              ),
            ),
            Spacer(),
            Slider(
              value: size,
              min: 10,
              max: 200,
              divisions: 19,
              onChanged: (val) {
                setState(() {
                  size = val;
                  print(val);
                });
              },
              activeColor: Colors.green,
              inactiveColor: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  int sides;
  double radius;
  double rad;
  Color color;
  double val;
  MyPainter({this.sides, this.radius, this.rad, this.color, this.val});

  drawMyPath({double size, Size center, double fromRadius, double toRadius}) {
    return new Path()
      ..moveTo(center.width / 2, center.height / 2)
      ..arcTo(
          Rect.fromCircle(
              radius: size,
              center: Offset(center.width / 2, center.height / 2)),
          fromRadius,
          toRadius,
          false)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    var path = Path();
    Offset center = Offset(size.width / 2, size.height / 2);
    double angle = (pi * 2) / sides;
    Offset start = Offset(radius * cos(rad), radius * sin(rad));
    path.moveTo(start.dx + center.dx, start.dy + center.dy);

    for (int i = 1; i <= sides; i++) {
      double x = radius * cos(rad + angle * i) + center.dx;
      double y = radius * sin(rad + angle * i) + center.dy;
      path.lineTo(x, y);
    }

    path.close();
    canvas.drawPath(path, paint);

    var paint2 = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    var path2 = Path();
    path2.moveTo(0, size.height * (0.8 - val / 4));
    path2.quadraticBezierTo(size.width * 0.25, size.height * (0.55 + val),
        size.width * 0.5, size.height * 0.75);
    path2.quadraticBezierTo(size.width * 0.75, size.height * (0.95 - val),
        size.width, size.height * (0.75 + val / 4));
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    canvas.drawPath(path2, paint2);

    var paint3 = Paint()
      ..color = Colors.red[900]
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    Paint getPaintColor(int i) {
      List<Color> colored = [
        Colors.red,
        Colors.yellow,
        Colors.green,
        Colors.pink,
        Colors.white,
        Colors.orange,
        Colors.brown,
        Colors.black
      ];
      var paint = Paint()
        ..color = colored[i]
        ..strokeWidth = 4
        ..style = PaintingStyle.fill;
      return paint;
    }

    double chartSize = 100;
    double radii = (2 * pi) / 8;

    canvas.drawPath(
        drawMyPath(
            size: chartSize, fromRadius: 0, center: size, toRadius: radii),
        getPaintColor(1));
    canvas.drawPath(
        drawMyPath(
            size: chartSize, fromRadius: radii, center: size, toRadius: radii),
        getPaintColor(2));
    canvas.drawPath(
        drawMyPath(
            size: chartSize,
            fromRadius: radii * 2,
            center: size,
            toRadius: radii),
        getPaintColor(0));
    canvas.drawPath(
        drawMyPath(
            size: chartSize,
            fromRadius: radii * 3,
            center: size,
            toRadius: radii),
        getPaintColor(4));
    canvas.drawPath(
        drawMyPath(
            size: chartSize,
            fromRadius: radii * 4,
            center: size,
            toRadius: radii),
        getPaintColor(5));
    canvas.drawPath(
        drawMyPath(
            size: chartSize,
            fromRadius: radii * 5,
            center: size,
            toRadius: radii),
        getPaintColor(6));
    canvas.drawPath(
        drawMyPath(
            size: chartSize,
            fromRadius: radii * 6,
            center: size,
            toRadius: radii),
        getPaintColor(7));
    canvas.drawPath(
        drawMyPath(
            size: chartSize,
            fromRadius: radii * 7,
            center: size,
            toRadius: radii),
        getPaintColor(3));
    final textSpan = TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 24),
        text: 'this is  it');
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 10, size.height * 0.8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
