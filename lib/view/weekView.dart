import 'package:flutter/material.dart';
import 'package:planner/view/dayView.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/view/taskDialogs.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/monthView.dart';

DatabaseService db = DatabaseService();

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            //Navigator.of(context).pop();
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const MonthView()));
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

    db.getListOfEventsInDay(date: getDateOnly(DateTime.now(), offsetDays:index)).then((value) => setState(() {
          eventCount = value.length;
          eventsToday = value;
        }));
    db.getTasksDueDay(DateTime.now()).then((value) => setState(() {
          taskCount = value.length;
          tasksDueToday = value;
        }));
  }
  int index;

  @override
  Widget build(BuildContext context) {
    DateTime dateToDisplay = getDateOnly(DateTime.now(), offsetDays: index);
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
                    const Text(
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        "Tasks"),
                    Expanded(
                      child: Row(
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
                          ),
                          Flexible(
                              flex: 0,
                              child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Card(
                                      child: InkWell(
                                          onTap: () async {
                                            await addTaskFormForDay(
                                                context, dateToDisplay);
                                          },
                                          child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_box)
                                              ])))))
                        ],
                      ),
                    ),
                    const Text(
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        "Events"),
                    Expanded(
                      child: Row(
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
                                          date: dateToDisplay)
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                          Flexible(
                              flex: 0,
                              child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Card(
                                      child: InkWell(
                                          onTap: () async {
                                            await addEventFormForDay(
                                                context, dateToDisplay);
                                          },
                                          child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_box)
                                              ])))))
                        ],
                      ),
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
  final DateTime date;
  const EventCard(
      {super.key,
      required this.eventsToday,
      required this.index,
      required this.date});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    Event event = widget.eventsToday[widget.index];
    return SizedBox(
      height: 40,
      width: 100,
      child: Card(
        color: Colors.amber,
        child: InkWell(
          onTap: () {
            showEventDetailPopup(context, event, widget.date);
          },
          child: Column(
            children: [
              Text(event.name),
              Text(
                  "${event.timeStart.hour}:${event.timeStart.minute} to ${event.timeEnd.hour}:${event.timeEnd.minute}"),
            ],
          ),
        ),
      ),
    );
  }
}
