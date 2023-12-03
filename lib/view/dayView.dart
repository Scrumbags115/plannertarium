import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/weekView.dart';
import 'package:planner/common/view/topbar.dart';

DatabaseService db = DatabaseService();

class DayView extends StatefulWidget {
  DateTime date;
  DayView({super.key, required this.date});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  ///A DatePicker function to prompt a calendar
  ///Returns a selectedDate if chosen, defaulted to today if no selectedDate
  Future<DateTime?> datePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      return selectedDate;
    }
    return widget.date;
  }

  /// A void function that asynchronously selects a date and fetches tasks for that date.
  Future<void> selectDate() async {
    DateTime selectedDate = await datePicker() ?? widget.date;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DayView(date: selectedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => WeekView()));
        }
      },
      child: Scaffold(
          appBar: getTopBar(Event, "daily", context, this),
          body: Stack(children: [
            SingleDay(widget.date),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0, 0, 20, 20), // Adjust the value as needed
                child: ClipOval(
                  child: ElevatedButton(
                    onPressed: () async {
                      await addEventFormForDay(context, widget.date);
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
            ),
          ])),
    );
  }
}

class SingleDay extends StatefulWidget {
  DateTime date;
  SingleDay(this.date, {super.key});

  @override
  _SingleDayState createState() => _SingleDayState(date);
}

class _SingleDayState extends State<SingleDay> {
  List<Event> eventsToday = [];
  List<int> eventStartHours = [];
  int eventCount = 0;

  _SingleDayState(DateTime date);

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  void asyncInitState() async {
    eventsToday = await db.getListOfEventsInDay(date: widget.date);
    eventCount = eventsToday.length;
    for (var event in eventsToday) {
      eventStartHours.add(event.timeStart.hour);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 50;
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
          itemCount: 24,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Column(children: [
                  SizedBox(
                      width: 50,
                      height: 40,
                      child: Center(
                        child: Text(intl.DateFormat('j').format(
                            getDateOnly(DateTime.now())
                                .add(Duration(hours: index)))),
                      )),
                ]),
                Expanded(
                  child: Column(
                    children: [
                      const Divider(
                        height: 1,
                        thickness: 2,
                      ),
                      paintEvents(index, width),
                    ],
                  ),
                )
              ],
            );
          },
        )),
      ],
    );
  }

  Row paintEvents(hour, width) {
    List<Event> eventsInHour = [];
    for (var event in eventsToday) {
      if (event.timeStart.hour == hour) {
        eventsInHour.add(event);
      }
    }
    double space = width / eventsInHour.length;
    //print("hour is $hour");
    //print("events starting in hour: $eventsInHour");
    List<CustomPaint> eventsToPaint = eventsInHour
        .map(
          (event) => CustomPaint(
            painter: MyPainter(context, eventSpace: space, event: event),
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  showEventDetailPopup(context, event, widget.date);
                },
                child:
                    SizedBox(width: space, child: const Card(color: Colors.black))),
          ),
        )
        .toList();
    return Row(children: eventsToPaint);
  }
}

class MyPainter extends CustomPainter {
  double eventSpace;
  Event event;
  final BuildContext context;
  MyPainter(this.context, {required this.eventSpace, required this.event});
  @override
  void paint(canvas, size) {
    final rrectPaint = Paint()
      ..strokeWidth = 10
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    final myPaint2 = Paint()
      ..strokeWidth = 2
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    RRect eventRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, eventSpace,
            40 * (event.timeEnd.hour - event.timeStart.hour).toDouble()),
        const Radius.circular(7.5));
    Path eventRRectBorder = Path();
    eventRRectBorder.addRRect(eventRRect);
    canvas.drawRRect(
      eventRRect,
      rrectPaint,
    );
    canvas.drawPath(eventRRectBorder, myPaint2);
    TextStyle eventNameStyle = const TextStyle(color: Colors.black, fontSize: 15);
    TextSpan eventNameSpan = TextSpan(text: event.name, style: eventNameStyle);
    TextPainter eventNamePainter =
        TextPainter(text: eventNameSpan, textDirection: (TextDirection.ltr));
    eventNamePainter.layout(minWidth: 0, maxWidth: size.width);
    eventNamePainter.paint(canvas, Offset.fromDirection(0, 6));
    TextStyle eventTimeStyle = const TextStyle(color: Colors.black, fontSize: 10.5);
    TextSpan eventTimeSpan = TextSpan(
        text:
            "${intl.DateFormat("h:mm").format(event.timeStart)} - ${intl.DateFormat("h:mma").format(event.timeEnd)}",
        style: eventTimeStyle);
    TextPainter eventTimePainter =
        TextPainter(text: eventTimeSpan, textDirection: (TextDirection.ltr));
    eventTimePainter.layout(minWidth: 0, maxWidth: size.width);
    eventTimePainter.paint(
        canvas, Offset.fromDirection(90, 20) + Offset.fromDirection(0, 16));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
