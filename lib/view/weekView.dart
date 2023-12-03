import 'package:flutter/material.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/view/dayView.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/monthView.dart';
import 'package:intl/intl.dart';

DatabaseService db = DatabaseService();

class WeekView extends StatefulWidget {
  late DateTime monday;
  WeekView({super.key, DateTime? date}) {
    monday = mostRecentMonday(date ?? DateTime.now());
  }

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  ///A DatePicker function to prompt a calendar
  ///Returns a selectedDate if chosen, defaulted to today if no selectedDate
  Future<void> datePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.monday,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        widget.monday = selectedDate;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WeekView(date: widget.monday),
        ),
      );
    }
  }

  void loadPreviousWeek() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            WeekView(date: getDateOnly(widget.monday, offsetDays: -7)),
      ),
    );
  }

  void loadNextWeek() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            WeekView(date: getDateOnly(widget.monday, offsetDays: 7)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = mostRecentMonday(widget.monday);
    return Scaffold(
      appBar: getTopBar(Event, "weekly", context, this),
      drawer: const Drawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MonthView()));
          }
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    DayView(date: getDateOnly(DateTime.now()))));
          }
        },
        child: Stack(
          children: [
            ListView(
              children: List.generate(DateTime.daysPerWeek, (index) {
                return MultiDayCard(index, startDate);
              }),
            ),
            AddEventButton(startDate: startDate)
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
                        builder: (context) => DayView(date: dateToDisplay)));
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
                          builder: (context) => DayView(date: dateToDisplay)));
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
        ),
      ]),
    );
  }
}
