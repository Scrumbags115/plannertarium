import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/weekView.dart';
import 'package:planner/common/view/topbar.dart';

DatabaseService db = DatabaseService();
const hourHeight = 50.0;
const displayedHourWidth = 50.0;

class DayView extends StatefulWidget {
  DateTime date;
  DayView({super.key, required this.date});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  ///A DatePicker function to prompt a calendar
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
            AddEventButton(startDate: widget.date)
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
    double width = MediaQuery.of(context).size.width - displayedHourWidth;
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
          itemCount: 24,
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                        width: displayedHourWidth,
                        child: Center(
                          child: Text(intl.DateFormat('j').format(
                              getDateOnly(DateTime.now())
                                  .add(Duration(hours: index)))),
                        )),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Divider(
                        height: 0,
                        thickness: 2,
                      ),
                      Container(
                          height: 40,
                          width: width,
                          child: OverflowBox(
                              minHeight: 40,
                              alignment: Alignment.topLeft,
                              maxHeight: MediaQuery.of(context).size.height,
                              child: paintEvents(index, width))),
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
    List<GestureDetector> eventsToPaint = eventsInHour
        .map(
          (event) => GestureDetector(
            onTap: () {
              showEventDetailPopup(context, event, widget.date);
            },
            child: CustomPaint(
              painter: MyPainter(context, eventWidth: space, event: event),
              child: Container(
                width: space,
                height: hourHeight,
              ),
            ),
          ),
        )
        .toList();
    return Row(children: eventsToPaint);
  }
}

class MyPainter extends CustomPainter {
  double eventWidth;
  Event event;
  final BuildContext context;
  MyPainter(this.context, {required this.eventWidth, required this.event});
  @override
  void paint(canvas, size) {
    final rrectPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    final myPaint2 = Paint()
      ..strokeWidth = 2
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    double hoursCovered =
        (event.timeEnd.hour - event.timeStart.hour).toDouble();
    if (hoursCovered == 0) {
      hoursCovered += 1;
    }
    double eventDuration =
        (event.timeEnd).difference(event.timeStart).inMinutes / 60;
    double hourOffset = event.timeStart.minute.toDouble() / 60;
    RRect eventRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
            0, hourHeight * hourOffset, eventWidth, hourHeight * eventDuration),
        const Radius.circular(7.5));
    Path eventRRectBorder = Path();
    eventRRectBorder.addRRect(eventRRect);
    canvas.drawRRect(
      eventRRect,
      rrectPaint,
    );
    canvas.drawPath(eventRRectBorder, myPaint2);
    TextStyle eventNameStyle =
        const TextStyle(color: Colors.black, fontSize: 15);
    TextSpan eventNameSpan = TextSpan(text: event.name, style: eventNameStyle);
    TextPainter eventNamePainter =
        TextPainter(text: eventNameSpan, textDirection: (TextDirection.ltr));
    eventNamePainter.layout(minWidth: 0, maxWidth: size.width);
    eventNamePainter.paint(
        canvas,
        Offset.fromDirection(90, hourHeight * hourOffset + 5) +
            Offset.fromDirection(0, 25));
    TextStyle eventTimeStyle =
        const TextStyle(color: Colors.black, fontSize: 10.5);
    TextSpan eventTimeSpan = TextSpan(
        text:
            "${intl.DateFormat("h:mm").format(event.timeStart)} - ${intl.DateFormat("h:mma").format(event.timeEnd)}",
        style: eventTimeStyle);
    TextPainter eventTimePainter =
        TextPainter(text: eventTimeSpan, textDirection: (TextDirection.ltr));
    eventTimePainter.layout(minWidth: 0, maxWidth: size.width);
    eventTimePainter.paint(
        canvas,
        Offset.fromDirection(90, hourHeight * hourOffset + 20) +
            Offset.fromDirection(0, 32));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
