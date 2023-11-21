import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/taskDialogs.dart';
import 'package:planner/view/eventDialogs.dart';
import 'dart:async';

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
        .getTasksDue(date, date.add(const Duration(days: 1)))
        .then((value) => setState(() {
              for (var val in value.values) {
                taskCount = val.length;
                tasksDueToday = val;
              }
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
                        /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddEventView(date)));*/
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EventDetailsView(
                                            item.name,
                                            item.description,
                                            item.location,
                                            item.timeStart,
                                            item.timeEnd)));
                              },
                              child: Center(child: Text(item.name))))),
                ))
            .toList());
  }
}

//TODO: make this a dialog instead of a full page
class TaskCard extends StatefulWidget {
  final List<Task> tasksDueToday;
  final int index;
  const TaskCard({super.key, required this.tasksDueToday, required this.index});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Color tilecolor = Colors.white;
  TextDecoration dec = TextDecoration.none;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 40,
        child: Card(
            color: tilecolor,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TaskDetailsView(
                          widget.tasksDueToday[widget.index].name,
                          widget.tasksDueToday[widget.index].description,
                          widget.tasksDueToday[widget.index].location)),
                );
              },
              onLongPress: () {
                if (tilecolor == Colors.white) {
                  widget.tasksDueToday[widget.index].completed =
                      !widget.tasksDueToday[widget.index].completed;
                  db.setTask(widget.tasksDueToday[widget.index]);
                  setState(() {
                    tilecolor = Colors.green;
                    dec = TextDecoration.lineThrough;
                  });
                } else {
                  setState(() {
                    widget.tasksDueToday[widget.index].completed =
                        !widget.tasksDueToday[widget.index].completed;
                    db.setTask(widget.tasksDueToday[widget.index]);
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
                    widget.tasksDueToday[widget.index].name),
              ),
            )));
  }
}

//TODO: make this a dialog instead of a full page
class AddTaskView extends StatelessWidget {
  final DateTime date;
  AddTaskView(this.date, {super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController taskLocationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter task name',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for this task';
                }
                return null;
              },
              controller: taskNameController,
              onSaved: (value) {
                taskNameController.text = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter task description',
              ),
              controller: taskDescriptionController,
              onSaved: (value) {
                taskDescriptionController.text = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter task location',
              ),
              controller: taskLocationController,
              onSaved: (value) {
                taskLocationController.text = value!;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    db.setTask(Task(
                        name: taskNameController.text,
                        description: taskDescriptionController.text,
                        location: taskLocationController.text,
                        timeDue: date));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//TODO: make this a dialog instead of a full page
class AddEventView extends StatelessWidget {
  final DateTime date;
  AddEventView(this.date, {super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  final TextEditingController tempTimeStartController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter event name',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for this event';
                }
                return null;
              },
              controller: eventNameController,
              onSaved: (value) {
                eventNameController.text = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter event description',
              ),
              controller: eventDescriptionController,
              onSaved: (value) {
                eventDescriptionController.text = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter event location',
              ),
              controller: eventLocationController,
              onSaved: (value) {
                eventLocationController.text = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter event start time',
              ),
              controller: tempTimeStartController,
              onSaved: (value) {
                tempTimeStartController.text = value!;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //Will have to replace this with a real time picker later
                    var temptimestart = DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day)
                        .add(Duration(
                            hours: int.parse(tempTimeStartController.text)));
                    db.addEvent(Event(
                        name: eventNameController.text,
                        description: eventDescriptionController.text,
                        location: eventLocationController.text,
                        timeStart: temptimestart,
                        timeEnd: temptimestart.add(Duration(hours: 1))));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//TODO: make this a dialog instead of a full page
class TaskDetailsView extends StatelessWidget {
  final String name;
  final String description;
  final String location;
  const TaskDetailsView(this.name, this.description, this.location,
      {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Description: $description"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Location: $location"),
            ),
          ],
        ));
  }
}

class EventDetailsView extends StatelessWidget {
  final String name;
  final String description;
  final String location;
  final DateTime start;
  final DateTime end;
  const EventDetailsView(
      this.name, this.description, this.location, this.start, this.end,
      {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Description: $description"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Location: $location"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Starts at: ${start.hour}:${start.minute}"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Ends at: ${end.hour}:${end.minute}"),
            ),
          ],
        ));
  }
}
