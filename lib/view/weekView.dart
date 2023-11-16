import 'package:flutter/material.dart';
import 'package:planner/view/dayView.dart';
import 'package:planner/common/database.dart';

DatabaseService dayta = DatabaseService(uid: "userid1");

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          body: ListView(
            children: List.generate(7, (index) {
              //This generates 7 MultiDayCard in a vertical list
              return MultiDayCard(index);
            }),
          ),
        ),
      ),
    );
  }
}

//Each of these navigates to dayView when tapped
class MultiDayCard extends StatefulWidget {
  const MultiDayCard(this.index, {super.key});
  final int index;

  @override
  State<StatefulWidget> createState() => _MultiDayCardState(index);
}

class _MultiDayCardState extends State<MultiDayCard> {
  _MultiDayCardState(this.index);
  int index;

  @override
  Widget build(BuildContext context) {
    DateTime dateToDisplay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .add(Duration(days: index));
    String monthDayDisplayed = "${dateToDisplay.month}/${dateToDisplay.day}";
    return Row(
      children: [
        Flexible(
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
              clipBehavior: Clip.hardEdge,
              elevation: 2,
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SingleDay(dateToDisplay)));
                },
                child: Expanded(child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(textAlign: TextAlign.left, "Tasks"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(textAlign: TextAlign.left, "Events"),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
