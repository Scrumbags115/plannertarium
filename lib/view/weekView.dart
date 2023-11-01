import 'package:flutter/material.dart';
import 'package:planner/view/dayView.dart';

class weekView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
        child: ListView(
          children: List.generate(7, (index) { //This generates 7 MultiDayCard in a vertical list
            return MultiDayCard(index);
          }),
        ),
      ),
    );
  }
}

//Each one of these is a day in the week view, consisting of the placeholder date and card to its right
class MultiDayCard extends StatefulWidget {
  const MultiDayCard(this.data);
  final int data;
  @override
  State<StatefulWidget> createState() => MultiDayCardState(data);
}

//being stateful doesn't really do anything right now, but I'm pretty sure we need it later on
class MultiDayCardState extends State<MultiDayCard> {
  MultiDayCardState(this.data);
  int data;
  @override
  Widget build(BuildContext context) {
    return Row(
      //This row contains: date placeholder, card
      children: [
        Flexible(
          //This widget and Expanded work together to make the card on the right stretch to fill space, works on mobile and web
          flex: 0,
          child: SizedBox(
            width: 70,
            height: 120,
            child: Center(
              child: Text(
                  "${DateTime.now().month}/${DateTime.now().day + data}"), //Doesn't really work to show the current week(October 32nd LMAO), just a placeholder
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 120,
            child: Card(
              //Not sure how to connect the backend to this kind of setup, but it looks kind of ok
              clipBehavior: Clip.hardEdge,
              elevation: 2,
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: InkWell(
                //Makes the splash effect when clicked/tapped, also navigates to the dayView
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => dayView()),
                  );
                },
                child: const Center(
                  child: Column(
                    children: [
                      Text("海阔天空"), //Placeholder text
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
