import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planner/view/dayView.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';
import 'package:planner/common/time_management.dart';

DatabaseService db = DatabaseService();

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
          appBar: AppBar(title: const Text("Week")),
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
  int eventCount = 0;
  int taskCount = 0;
  List<Event> eventsToday = [];
  List<Task> tasksDueToday = [];
  _MultiDayCardState(this.index) {
    DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: index));
    
    db.getListOfEventsInDay(date: getDateOnly(DateTime.now(), offset:index)).then((value) => setState(() {
          eventCount = value.length;
          eventsToday = value;
        }));

    db.getTasksDue(getDateOnly(DateTime.now(), offset:index), date.add(const Duration(days: 1))).then((value) => setState(() {
          for (var val in value.values) {
            taskCount = val.length;
            tasksDueToday = val;
          }
        }));
  }
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
                child: Column(
                  children: [
                    const Text(style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left, "Tasks"),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(taskCount, (index) {
                                return Row(
                                  children: [
                                    TaskCard(
                                      tasksDueToday: tasksDueToday,
                                      index: index,
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                        )
                      ],
                    ),
                    const Text(style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left, "Events"),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(eventCount, (index) {
                                return Row(
                                  children: [
                                    EventCard(
                                      eventsToday: eventsToday,
                                      index: index,
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatefulWidget {
  final List<Event> eventsToday;
  final int index;
  const EventCard({super.key, required this.eventsToday, required this.index});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 100,
      child: Card(
        color: Colors.amber,
        child: InkWell(
          onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventDetailsView(
                          widget.eventsToday[widget.index].name,
                          widget.eventsToday[widget.index].description,
                          widget.eventsToday[widget.index].location,
                          widget.eventsToday[widget.index].timeStart,
                          widget.eventsToday[widget.index].timeEnd,)),
                );
          },
          child: Column(
            children: [
              Text(widget.eventsToday[widget.index].name),
              Text("${widget.eventsToday[widget.index].timeStart.hour}:${widget.eventsToday[widget.index].timeStart.minute} to ${widget.eventsToday[widget.index].timeEnd.hour}:${widget.eventsToday[widget.index].timeEnd.minute}"),
            ],
          ),
        ),
      ),
    );
  }
}