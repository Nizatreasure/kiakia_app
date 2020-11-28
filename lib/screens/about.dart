import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Text('Leading the energy Transition in Africa',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 22),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            Text(
              'Gas360 is a technology company that bridges the distribution gap in providing clean energy to the last mile customer.\n\nOur mission is to increase access to, and affordability of, clean energy for all families.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 17),
            )
          ],
        ),
      ),
    );
  }
}
