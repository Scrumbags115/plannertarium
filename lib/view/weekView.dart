import 'package:flutter/material.dart';
import 'package:planner/view/dayView.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/view/taskDialogs.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/monthView.dart';
import 'package:planner/view/taskView.dart';

DatabaseService db = DatabaseService();

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  bool forEvents = true;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime start = mostRecentMonday(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MonthView()));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Tasks ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Switch(
                        // thumb color (round icon)
                        activeColor: Colors.white,
                        activeTrackColor: Colors.cyan,
                        inactiveThumbColor: Colors.blueGrey.shade600,
                        inactiveTrackColor: Colors.grey.shade400,
                        splashRadius: 50.0,
                        value: forEvents,
                        onChanged: (value) {
                          setState(() {
                            forEvents = value;
                          });
                          if (!forEvents) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => taskView(),
                              ),
                            );
                          }
                        },
                      ),
                      const Text(
                        ' Events',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                  icon: const Icon(
                      color: Colors.black, Icons.calendar_month_rounded),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        start = picked;
                      });
                    }
                  }),
            ],
          ),
          body: ListView(
            children: List.generate(7, (index) {
              //This generates 7 MultiDayCard in a vertical list
              return MultiDayCard(index, start);
            }),
          ),
        ),
      ),
    );
  }
}

//Each of these navigates to dayView when tapped
class MultiDayCard extends StatefulWidget {
  const MultiDayCard(this.index, this.start, {super.key});
  final int index;
  final DateTime start;

  @override
  State<StatefulWidget> createState() => _MultiDayCardState(index, start);
}

class _MultiDayCardState extends State<MultiDayCard> {
  int eventCount = 0;
  int taskCount = 0;
  List<Event> eventsToday = [];
  List<Task> tasksDueToday = [];
  _MultiDayCardState(this.index, this.start) {
    db
        .getListOfEventsInDay(date: getDateOnly(start, offsetDays: index))
        .then((value) => setState(() {
              eventCount = value.length;
              eventsToday = value;
            }));
    db
        .getTasksDueDay(getDateOnly(start, offsetDays: index))
        .then((value) => setState(() {
              taskCount = value.length;
              tasksDueToday = value;
            }));
  }
  int index;
  DateTime start;

  @override
  Widget build(BuildContext context) {
    DateTime dateToDisplay = getDateOnly(start, offsetDays: index);
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
                                      /*TaskCard(
                                        tasksDueToday: tasksDueToday,
                                        index: index,
                                      )*/
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
