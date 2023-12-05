import 'package:flutter/material.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/view/dailyEventView.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/monthlyEventView.dart';
import 'package:intl/intl.dart';

class WeeklyEventView extends StatefulWidget {
  late DateTime monday;
  WeeklyEventView({super.key, DateTime? date}) {
    monday = mostRecentMonday(date ?? DateTime.now());
  }

  @override
  State<WeeklyEventView> createState() => _WeeklyEventViewState();
}

class _WeeklyEventViewState extends State<WeeklyEventView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseService db = DatabaseService();
  void resetView(DateTime? selectedDate) async {
    if (selectedDate == null) {
      return;
    }
    setState(() {
      widget.monday = selectedDate;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WeeklyEventView(date: widget.monday),
      ),
    );
  }

  void loadPreviousWeek() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            WeeklyEventView(date: getDateOnly(widget.monday, offsetDays: -7)),
      ),
    );
  }

  void loadNextWeek() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            WeeklyEventView(date: getDateOnly(widget.monday, offsetDays: 7)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = mostRecentMonday(widget.monday);
    DateTime today = DateTime.now();
    return Scaffold(
      appBar: getTopBar(Event, "weekly", context, this),
      drawer: const Drawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MonthlyEventView()));
          }
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    DailyEventView(date: getDateOnly(DateTime.now()))));
          }
        },
        child: Stack(
          children: [
            ListView(
              children: List.generate(DateTime.daysPerWeek, (index) {
                return MultiDayCard(index, startDate);
              }),
            ),
            AddEventButton(startDate: startDate, events: [], viewPeriod: "week")
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
  DatabaseService db = DatabaseService();
  _MultiDayCardState(this.index, this.startDate) {
    // todo: eventWeeklyView is currently implemented as a list of events in a day. This doesn't support/deal with events with overlapping time frames. For example, event A and B could be from 3-4PM Dec 1 and 2 respectively, but grabbing it with getListOfEventsInDay() for Dec 1 can return both if event A's timeEnd and eventB's timeStart are in range, as it expects the user to deal with overlapping times over a current day
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
                        builder: (context) =>
                            DailyEventView(date: dateToDisplay)));
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
                          builder: (context) =>
                              DailyEventView(date: dateToDisplay)));
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: generateEventCardListView(dateToDisplay),
                          ),
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
      //This Expanded > Row > Expanded is necessary to prevent ParentDataWidget error
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: Card(
              color: Colors.amber,
              child: InkWell(
                onTap: () {
                  showEventDetailPopup(context, event, widget.date,
                      viewPeriod: "week");
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
        ),
      ]),
    );
  }
}
