import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:planner/models/event.dart';

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
          appBar: AppBar(title: Text("Day View")),
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
                      //Takes you to the screen to add a task
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddTaskView(date)));
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
                                height: 10,
                                thickness: 2.5,
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
          Stack(children: [
            Container(
              decoration: const BoxDecoration(),
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [],
                ),
              ),
            ),
            generateEventsInHour(counter),
          ]),
        ],
      );
    } else {
      return const Row();
    }
  }

  Row generateEventsInHour(hour) {
    List<Event> eventsInHour = [];
    for (var event in eventsToday) {
      if (event.timeStart.isAfter(date.add(Duration(hours: hour))) && event.timeEnd.isBefore(date.add(Duration(hours: hour+2)))) {
        eventsInHour.add(event);
        print(date.add(Duration(hours: hour)));
        print(date.add(Duration(hours: hour + 2)));
        print(event.timeStart);
        print(event.timeEnd);
      }
    }
    return Row(
      children: eventsInHour.map((item) => new Text("$item")).toList()
      /*SizedBox(
              height: 40,
              width: 40,
              child: Card(color: Colors.red, child: Text("$hour"))),
        SizedBox(
            height: 40,
            width: 40,
            child: Card(color: Colors.red, child: Text("hi")))*/
      ,
    );
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
