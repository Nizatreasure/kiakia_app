import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';

class FAQ extends StatefulWidget {
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> with TickerProviderStateMixin {
  ScrollController _scrollController;
  List<AnimationController> _animationController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {});
    _animationController = List.generate(
        questions.length,
        (index) => AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 300),
            reverseDuration: Duration(milliseconds: 300)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void playAnimation(int index) {
      if (questions[index].expanded) {
        for (int i = 0; i < _animationController.length; i++)
          _animationController[i].reverse();
        _animationController[index].forward();
      } else
        _animationController[index].reverse();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("FAQ"),
        centerTitle: true,
        toolbarHeight: 60,
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
      body: ListView.builder(
        controller: _scrollController,
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              GestureDetector(
                onTap: () async {
                  setState(() {
                    for (var item in questions) {
                      if (item.question != questions[index].question)
                        item.expanded = false;
                    }
                  });
                  await Future.delayed(Duration(milliseconds: 50));
                  setState(() {
                    questions[index].expanded = !questions[index].expanded;
                    playAnimation(index);
                    if (questions[index].expanded)
                      _scrollController.animateTo(70.0 * (index - 1),
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic);
                  });
                },
                child: Container(
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(77, 172, 246, 0.05),
                      border: BorderDirectional(
                          bottom: BorderSide(color: Colors.grey[300]))),
                  child: ListTile(
                    title: Text(
                      questions[index].question,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: AnimatedIconButton(
                      startIcon: Icon(Icons.keyboard_arrow_down),
                      endIcon: Icon(Icons.keyboard_arrow_up),
                      animationController: _animationController[index],
                      onPressed: () async {
                        setState(() {
                          for (var item in questions) {
                            if (item.question != questions[index].question)
                              item.expanded = false;
                          }
                        });
                        await Future.delayed(Duration(milliseconds: 50));
                        setState(() {
                          questions[index].expanded =
                              !questions[index].expanded;
                          playAnimation(index);
                          if (questions[index].expanded)
                            _scrollController.animateTo(70.0 * (index - 1),
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOutCubic);
                        });
                      },
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: questions[index].expanded,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    questions[index].answer,
                    textAlign: TextAlign.justify,
                    style: TextStyle(height: 1.5),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  List<FAQComponents> questions = [
    FAQComponents(
        answer:
            'LPG is the acronym for Liquefied Petroleum Gas (also known as cooking gas). It’s a mixture of propane and butane. It has different purposes, most relevant being for cooking food. It also does not release considerable amounts of carbon dioxide, sulphur or particulate matter into the environment, which is why it is safe for one\'s health and the environment.',
        question: 'What exactly is LPG?',
        expanded: false),
    FAQComponents(
        question: 'Is LPG safe?',
        answer:
            'Yes, LPG is safe to use. There are concerns about explosions but this only happens due to faulty cylinders, and leakages. GAS360 uses her patent technology attached to  our cylinders, which will inform you of any gas leakage. Also, our cylinders are regularly checked and certified to avoid using faulty cylinders in our exchange pool.',
        expanded: false),
    FAQComponents(
        answer:
            'With GAS360, you only have to place an order for LPG to be delivered to you and our riders would deliver the requested quantity of LPG to you within 45minutes. You will receive a full cylinder while your empty cylinder is collected by our rider. Our patented technology suite allows you to monitor your LPG consumption to prevent you running out of LPG; hence once your LPG is low, you will receive a notification to schedule the next LPG delivery before you run out of Gas.',
        question: 'How does GAS360 work?',
        expanded: false),
    FAQComponents(
        question:
            'How does our Smart Cylinder Exchange Network (discuss cylinder expiry and management).',
        answer:
            'Our cylinder exchange system is a pool of certified LPG cylinders that are safe for customer usage operates by having a pool of cylinders by the LPG supplier. Our cylinders are pre-filled and deployed to the home of a customer upon receiving the order and the customer’s cylinder is received into the pool. This system reduces time the customer spends waiting for the cylinder to be filled and delivered. Also, the cylinders being managed by the LPG supplier means only certified cylinders would be used in the pool, and by extension by customers, thereby reducing the risk of explosions.',
        expanded: false),
    FAQComponents(
        question:
            'As an existing Gas User Do I need to buy a new cylinder to use GAS360?',
        answer:
            'You’ll only need a new cylinder if your current cylinder was manufactured before 2015. Cylinders have a 15-year life span and a 5-year recertification timeline. The year of manufacture can be seen at the top (handle) of the cylinder. Expired cylinders are not accepted into the pool for the sake of safety, however there are options to pay small-small for a new safe cylinder.  Having an expired cylinder does not cancel your purchase.',
        expanded: false),
    FAQComponents(
        question:
            'As a New Gas User Do I need to buy a new cylinder to use GAS360?',
        answer:
            'You’ll need to purchase a new cylinder if you don’t have a cylinder currently.',
        expanded: false),
    FAQComponents(
        question: 'How does monitoring my gas consumption help?',
        answer:
            'The ability to monitor your cylinder allows us to prevent you from running out of LPG while cooking. The experience of your LPG getting exhausted while cooking, in the night, is never a great experience. GAS360 prevents such unfavourable events from occurring.',
        expanded: false),
    FAQComponents(
        question: 'Do I have to pay separately for delivery?',
        answer:
            'No, you do not need to pay separately for delivery. Delivery is free.',
        expanded: false),
    FAQComponents(
        question: 'What locations do you currently operate in?',
        answer:
            'We are currently operating in Lekki, Lagos State. We would be coming to your location soon. (Fill this form so we can come to your location first)',
        expanded: false),
    FAQComponents(
        question: 'Can I also buy cooking-related accessories?',
        answer:
            'Yes you can. We provide accessories such as regulators, cookers, burners and hoses. You can visit our product store here: [link to product store].',
        expanded: false),
    FAQComponents(
        question: 'How does the subscription work?',
        answer:
            'Subscription allows you to pay for Gas deliveries ahead of time, giving you discounts based on how far into the future you are subscribing for. This also removes the worry of having to pay every single time you buy LPG.',
        expanded: false)
  ];
}

class FAQComponents {
  String question, answer;
  bool expanded;
  FAQComponents(
      {@required this.question,
      @required this.answer,
      @required this.expanded});
}
