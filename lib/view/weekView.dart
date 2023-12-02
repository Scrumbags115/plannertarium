import 'package:flutter/material.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/view/dayView.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/monthView.dart';
import 'package:intl/intl.dart';
import 'package:planner/view/weeklyTaskView.dart';

DatabaseService db = DatabaseService();

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  bool forEvents = true;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime startDate = mostRecentMonday(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getTopBar(Event, "weekly", context, this),
      drawer: Drawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MonthView()));
          }
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DayView(getDateOnly(DateTime.now()))));
          }
        },
        child: Stack(
          children: [
            ListView(
              children: List.generate(DateTime.daysPerWeek, (index) {
                //This generates 7 MultiDayCard in a vertical list
                return MultiDayCard(index, startDate);
              }),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0, 0, 20, 20), // Adjust the value as needed
                child: ClipOval(
                  child: ElevatedButton(
                    onPressed: () async {
                      await addEventFormForDay(context, startDate);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: const Size(75, 75),
                    ),
                    child: const Icon(
                      Icons.add_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MultiDayCard extends StatefulWidget {
  const MultiDayCard(this.index, this.startDate, {super.key});
  final int index;
  final DateTime startDate;

  @override
  State<StatefulWidget> createState() => _MultiDayCardState(index, startDate);
}

class _MultiDayCardState extends State<MultiDayCard> {
  int eventCount = 0;
  List<Event> eventsToday = [];
  int index;
  DateTime startDate;
  _MultiDayCardState(this.index, this.startDate) {
    db
        .getListOfEventsInDay(date: getDateOnly(startDate, offsetDays: index))
        .then((value) {
      if (mounted) {
        setState(() {
          eventCount = value.length;
          eventsToday = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    startDate = widget.startDate;
    DateTime dateToDisplay = getDateOnly(startDate, offsetDays: index);
    String monthDayDisplayed = "${dateToDisplay.month}/${dateToDisplay.day}";
    db
        .getListOfEventsInDay(date: getDateOnly(startDate, offsetDays: index))
        .then((value) {
      if (mounted) {
        setState(() {
          eventCount = value.length;
          eventsToday = value;
        });
      }
    });
    return Row(
      children: [
        Flexible(
          flex: 0,
          child: SizedBox(
            width: 70,
            height: 140,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DayView(dateToDisplay)));
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('EE')
                        .format(getDateOnly(startDate, offsetDays: index))),
                    Text(monthDayDisplayed),
                  ],
                ),
              ),
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
                          builder: (context) => DayView(dateToDisplay)));
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: generateEventCardListView(dateToDisplay),
                          ),
                          /*Flexible(
                              flex: 0,
                              child: SizedBox(
                                  width: 40,
                                  child: Card(
                                      color: Colors.blue,
                                      child: InkWell(
                                          onTap: () async {
                                            await addEventFormForDay(
                                                context, dateToDisplay);
                                          },
                                          child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [Icon(Icons.add)])))))*/
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

  ListView generateEventCardListView(DateTime dateToDisplay) {
    if (eventCount == 0) {
      return ListView(
        shrinkWrap: true,
        children: List.generate(eventCount, (index) {
          return Row(
            children: [
              EventCard(
                  eventsToday: eventsToday, index: index, date: dateToDisplay)
            ],
          );
        }),
      );
    } else {
      return ListView(
        shrinkWrap: true,
        children: List.generate(eventCount, (index) {
          return Row(
            children: [
              EventCard(
                  eventsToday: eventsToday, index: index, date: dateToDisplay)
            ],
          );
        }),
      );
    }
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
    return Expanded(
      child: SizedBox(
        height: 40,
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
                    "${DateFormat("h:mma").format(event.timeStart)} to ${DateFormat("h:mma").format(event.timeEnd)}")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
