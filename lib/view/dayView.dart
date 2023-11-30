import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/eventDialogs.dart';

DatabaseService db = DatabaseService();

//The entirety of the dayView is one SingleDay
class SingleDay extends StatefulWidget {
  final DateTime date;
  const SingleDay(this.date, {super.key});

  @override
  _SingleDayState createState() => _SingleDayState(date);
}

class _SingleDayState extends State<SingleDay> {
  DateTime date;
  List<Event> eventsToday = [];
  int eventCount = 0;
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
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text("${date.month}/${date.day}")),
          body: Column(
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
        ),
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
}
