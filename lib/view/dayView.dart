import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/taskView.dart';
import 'package:planner/view/weekView.dart';
import 'package:planner/common/view/topbar.dart';

DatabaseService db = DatabaseService();

class DayView extends StatefulWidget {
  DayView(this.date, {super.key});
  DateTime date;

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

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
            )
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

  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        /*Flexible(
                          flex: 0,
                          child: SizedBox(
                            width: 50,
                            child: Center(
                              child: Text(DateFormat('j').format(
                                  getDateOnly(DateTime.now())
                                      .add(Duration(hours: index)))),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            height: 1,
                            thickness: 2,
                            color: Colors.lightBlueAccent,
                          ),
                        ),*/
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
                          child: Stack(
                            children: [
                              Divider(
                                height: 1,
                                thickness: 2,
                              ),
                              generateEventsInHour(index),
                            ],
                          ),
                        )
                      ],
                    ),
                    /*SizedBox(
                        height: 40,
                        child: Card(color: Colors.black, child: Text("hi")))*/
                  ],
                );
              },
            ),
          )
        ],
      ),
    ]);
  }

  Map<int, Row> generateHours() {
    Map<int, Row> hours = {};
    for (int i = 0; i < 24; i++) {
      hours.addEntries([MapEntry(i, Row())]);
    }
    for (int i = 0; i < 24; i++) {
      List<Event> eventsInHour = [];
      for (var event in eventsToday) {
        if (event.timeStart.hour <= i && event.timeEnd.hour >= i + 1) {
          eventsInHour.add(event);
        }
      }
      if (eventsInHour.length != 0) {
        hours[i] = Row(
          children: [SizedBox(height: 50, child: Text("hi"))],
        );
      } else {
        hours[i] = Row(
          children: [
            SizedBox(
              height: 40,
            )
          ],
        );
      }
    }
    return hours;
  }

  Row generateEventsInHour(hour) {
    Set<int> h = {};
    List<Event> eventsInHour = [];
    /*for (var event in eventsToday) {
      if (event.timeStart.hour <= hour && event.timeEnd.hour >= hour + 1) {
        eventsInHour.add(event);
      }
    }*/
    for (var hr in eventStartHours) {
      if (hr == hour) {
        h.add(hr);
      }
    }
    for (var i in h) {
      for (var event in eventsToday) {
        if (event.timeStart.hour == i) {
          eventsInHour.add(event);
        }
      }
    }
    double width = MediaQuery.of(context).size.width - 50;
    double space = width / eventCount;
    return Row(
        children: /*eventsInHour
              .map((item) => Expanded(
                    child: SizedBox(
                        height: 40,
                        child: Card(
                            color: Colors.amber,
                            child: InkWell(
                                onTap: () {
                                  showEventDetailPopup(
                                      context, item, widget.date);
                                },
                                child: Center(child: Text(item.name))))),
                  ))
              .toList());*/
            eventsInHour
                .map((item) => CustomPaint(
                    painter: MyPainter(eventSpace: space, event: item),
                    child: SizedBox(width: space + 10)))
                .toList());
  } /*Column(
      children: [
        Expanded(
          child: ListView(
            children: List.generate(24, (index) {
              int displaynum;
              String ampm;
              if (index % 12 == 0) {
                displaynum = 12;
              } else if (index > 12) {
                displaynum = index - 12;
              } else {
                displaynum = index;
              }
              if (index > 11) {
                ampm = "PM";
              } else {
                ampm = "AM";
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 0,
                        child: SizedBox(
                          width: 50,
                          child: Center(
                            child: Text("$displaynum $ampm"),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          height: 1,
                          thickness: 2,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                  generateHourBox(index),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Row generateHourBox(int counter) {
    if (counter < 24) {
      return Row(
        children: [
          const Flexible(
            flex: 0,
            child: SizedBox(
              width: 45,
              child: Center(),
            ),
          ),
          Expanded(
            child: Stack(children: [
              Container(
                decoration: const BoxDecoration(),
                child: SizedBox(
                    height: 50,
                    child: InkWell(
                      onTap: () async {
                        await addEventFormForDay(context, date);
                      },
                    )),
              ),
              generateEventsInHour(counter),
            ]),
          ),
        ],
      );
    } else {
      return const Row();
    }
  }

  Row generateEventsInHour(hour) {
    List<Event> eventsInHour = [];
    for (var event in eventsToday) {
      if (event.timeStart.hour <= hour && event.timeEnd.hour >= hour + 1) {
        eventsInHour.add(event);
      }
    }
    return Row(
        children: eventsInHour
            .map((item) => Expanded(
                  child: SizedBox(
                      height: 50,
                      child: Card(
                          color: Colors.amber,
                          child: InkWell(
                              onTap: () {
                                showEventDetailPopup(context, item, date);
                              },
                              child: Center(child: Text(item.name))))),
                ))
            .toList());
  }*/
}

class MyPainter extends CustomPainter {
  double eventSpace;
  Event event;
  MyPainter({required this.eventSpace, required this.event});
  @override
  void paint(canvas, size) {
    final myPaint = Paint()
      ..strokeWidth = 10
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(5, 0, eventSpace,
            40 * (event.timeEnd.hour - event.timeStart.hour).toDouble()),
        myPaint);
    TextStyle textStyle = TextStyle(color: Colors.black, fontSize: 15);
    TextSpan textSpan = TextSpan(text: event.name, style: textStyle);
    TextPainter textPainter =
        TextPainter(text: textSpan, textDirection: (TextDirection.rtl));
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, Offset.fromDirection(0, 6));
    textStyle = TextStyle(color: Colors.black, fontSize: 10.5);
    textSpan = TextSpan(
        text:
            "${intl.DateFormat("h:mm").format(event.timeStart)} - ${intl.DateFormat("h:mma").format(event.timeEnd)}",
        style: textStyle);
    textPainter =
        TextPainter(text: textSpan, textDirection: (TextDirection.ltr));
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
        canvas, Offset.fromDirection(90, 20) + Offset.fromDirection(0, 16));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
/*class SingleDay extends StatefulWidget {
  DateTime date;
  SingleDay(this.date, {super.key});

  @override
  _SingleDayState createState() => _SingleDayState(date);
}

class _SingleDayState extends State<SingleDay> {
  DateTime date;
  List<Event> eventsToday = [];
  int eventCount = 0;
  bool forEvents = true;
  _SingleDayState(this.date) {
    db.getListOfEventsInDay(date: date).then((value) => setState(() {
          eventCount = value.length;
          eventsToday = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => WeekView()));
          }
        },
        child: //Scaffold(
          /*appBar: AppBar(
              elevation: 1,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )),
              backgroundColor: Colors.white,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      "${date.month}/${date.day}"),
                ],
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
                                  builder: (context) => TaskView(),
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
                MenuAnchor(
                  builder: (BuildContext context, MenuController controller,
                      Widget? child) {
                    return IconButton(
                      color: Colors.black,
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'Show menu',
                    );
                  },
                  menuChildren: [
                    IconButton(
                        icon: const Icon(
                            color: Colors.black, Icons.calendar_month_rounded),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setState(() {
                              date = picked;
                            });
                          }
                        }),
                    IconButton(
                        icon: const Icon(color: Colors.black, Icons.east),
                        onPressed: () {
                          setState(() {
                            date = getDateOnly(date, offsetDays: 1);
                          });
                        }),
                    IconButton(
                        icon: const Icon(color: Colors.black, Icons.west),
                        onPressed: () {
                          setState(() {
                            date = getDateOnly(date, offsetDays: -1);
                          });
                        })
                  ],
                )
              ]),
          body:*/ Column(
            children: [
              Expanded(
                child: ListView(
                  children: List.generate(24, (index) {
                    int displaynum;
                    String ampm;
                    if (index % 12 == 0) {
                      displaynum = 12;
                    } else if (index > 12) {
                      displaynum = index - 12;
                    } else {
                      displaynum = index;
                    }
                    if (index > 11) {
                      ampm = "PM";
                    } else {
                      ampm = "AM";
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              flex: 0,
                              child: SizedBox(
                                width: 50,
                                child: Center(
                                  child: Text("$displaynum $ampm"),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                height: 1,
                                thickness: 2,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),
                        generateHourBox(index),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        //),
      ),
    );
  }

  Row generateHourBox(int counter) {
    if (counter < 24) {
      return Row(
        children: [
          const Flexible(
            flex: 0,
            child: SizedBox(
              width: 45,
              child: Center(),
            ),
          ),
          Expanded(
            child: Stack(children: [
              Container(
                decoration: const BoxDecoration(),
                child: SizedBox(
                    height: 50,
                    child: InkWell(
                      onTap: () async {
                        await addEventFormForDay(context, date);
                      },
                    )),
              ),
              generateEventsInHour(counter),
            ]),
          ),
        ],
      );
    } else {
      return const Row();
    }
  }

  Row generateEventsInHour(hour) {
    List<Event> eventsInHour = [];
    for (var event in eventsToday) {
      if (event.timeStart.hour <= hour && event.timeEnd.hour >= hour + 1) {
        eventsInHour.add(event);
      }
    }
    return Row(
        children: eventsInHour
            .map((item) => Expanded(
                  child: SizedBox(
                      height: 50,
                      child: Card(
                          color: Colors.amber,
                          child: InkWell(
                              onTap: () {
                                showEventDetailPopup(context, item, date);
                              },
                              child: Center(child: Text(item.name))))),
                ))
            .toList());
  }
}*/
