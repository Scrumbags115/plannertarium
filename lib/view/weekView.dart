import 'package:flutter/material.dart';
import 'package:planner/view/dayView.dart';

class weekView extends StatelessWidget {
  const weekView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: List.generate(7, (index) {
          //This generates 7 MultiDayCard in a vertical list
          return MultiDayCard(index);
        }),
      ),
    );
  }
}

///Each one of these is a day in the week view, consisting of the placeholder date and card to its right
class MultiDayCard extends StatefulWidget {
  MultiDayCard(this.index, {super.key});
  final int index;
  @override
  State<StatefulWidget> createState() => MultiDayCardState(index);
}

class MultiDayCardState extends State<MultiDayCard> {
  MultiDayCardState(this.index);
  int index;

  @override
  Widget build(BuildContext context) {
    var dateToDisplay = DateTime.now().add(Duration(days: index));
    String monthDayDisplayed = "${dateToDisplay.month}/${dateToDisplay.day}";
    return Row(
      //This row contains: date, card
      children: [
        Flexible(
          //This widget and Expanded work together to make the card on the right stretch to fill space, works on mobile and web
          flex: 0,
          child: SizedBox(
            width: 70,
            height: 140,
            child: Center(
              child: Text(monthDayDisplayed),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 140,
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
                    MaterialPageRoute(
                        builder: (context) => SingleDay(dateToDisplay)),
                  );
                },
                child: const Center(
                  child: Column(
                    children: [
                      //Text("Placeholder"), //Placeholder text
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
