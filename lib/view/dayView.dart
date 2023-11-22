import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/taskDialogs.dart';
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
  List<Task> tasksDueToday = [];
  List<Event> eventsToday = [];
  int taskCount = 0;
  int eventCount = 0;
  _SingleDayState(this.date) {
    db.getListOfEventsInDay(date: date).then((value) => setState(() {
          eventCount = value.length;
          eventsToday = value;
        }));
    db
        .getTasksDueDay(date)
        .then((taskList) => setState(() {
              taskCount = taskList.length;
              tasksDueToday = taskList;
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
              //Displays the tasks for the day, along with the add task button
              SizedBox(
                height: 80,
                child: Card(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 5.0, top: 8.0),
                                  child: Text(
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      "Tasks for today!"),
                                ),
                              ],
                            ),
                            Expanded(
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: List.generate(taskCount, (index) {
                                    return Row(
                                      children: [
                                        TaskCard(
                                            tasksDueToday: tasksDueToday,
                                            index: index),
                                      ],
                                    );
                                  })),
                            ),
                          ],
                        ),
                      ),
                      //Opens a dialog form to add a task for the day that is being viewed
                      TextButton(
                        onPressed: () async {
                          await addTaskFormForDay(context, date);
                        },
                        child: Container(
                          color: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: const Text(
                            'Add Task',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class TaskCard extends StatefulWidget {
  final List<Task> tasksDueToday;
  final int index;
  const TaskCard({super.key, required this.tasksDueToday, required this.index});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  TextDecoration dec = TextDecoration.none;

  @override
  Widget build(BuildContext context) {
    Task task = widget.tasksDueToday[widget.index];
    Color tilecolor = Colors.white;
    if (task.completed) {
      tilecolor = Colors.green;
    }
    return SizedBox(
        height: 40,
        child: Card(
            color: tilecolor,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () async {
                showTaskDetailPopup(context, task);
              },
              onLongPress: () {
                if (tilecolor == Colors.white) {
                  task.completed = !task.completed;
                  db.setTask(task);
                  setState(() {
                    tilecolor = Colors.green;
                    dec = TextDecoration.lineThrough;
                  });
                } else {
                  setState(() {
                    task.completed = !task.completed;
                    db.setTask(task);
                    tilecolor = Colors.white;
                    dec = TextDecoration.none;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    style: TextStyle(
                        decoration: dec,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    task.name),
              ),
            )));
  }
}
