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
  SingleDayState createState() => SingleDayState(date);
}

class SingleDayState extends State<SingleDay> {
  DateTime date;
  List<Task> tasksDueToday = [];
  List<Event> currentEvents = [];
  int taskCount = 0;
  SingleDayState(this.date) {
    getCurrentEvents() {
      return db.getListOfEventsInDay(date: date);
    }

    getCurrentEvents().then((value) => setState(() {}));
    getTasksDueToday() {
      return db.getTasksDue(date, date.add(const Duration(days: 1)));
    }

    getTasksDueToday().then((value) => setState(() {
          for (var val in value.values) {
            taskCount = val.length;
            tasksDueToday = val;
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: Card(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            "Tasks for today!"),
                        Expanded(
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(taskCount, (index) {
                                return Row(
                                  children: [
                                    SizedBox(
                                        height: 40,
                                        child: Card(
                                            color: Colors.amber,
                                            child: InkWell(
                                              splashColor:
                                                  Colors.blue.withAlpha(30),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          taskDetails(
                                                              tasksDueToday[
                                                                      index]
                                                                  .name,
                                                              tasksDueToday[
                                                                      index]
                                                                  .description,
                                                              tasksDueToday[
                                                                      index]
                                                                  .location)),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                    tasksDueToday[index].name),
                                              ),
                                            ))),
                                  ],
                                );
                              })),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddTask(date)));
                    },
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: const Text(
                        'Add Task',
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
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
                              child:
                                  Text("$displaynum $ampm"), //Placeholder hour
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
            child: Container(
              decoration: const BoxDecoration(
                  //Makes a gray box that doesn't do anything right now
                  //color: Color(0xFFBFBFBF),
                  ),
              child: SizedBox(
                //Also not idea how I'm going to connect the backend with this, but better to have something than nothing
                height: 50,
                child: InkWell(
                  splashColor: Colors.red.withAlpha(30),
                  onTap: () {},
                  child: const Center(
                    child: Column(
                      children: [
                        //Text("Placeholder"), //Placeholder
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const Row();
    }
  }
}

class AddTask extends StatelessWidget {
  final DateTime date;
  AddTask(this.date, {super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController taskLocationController = TextEditingController();

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
                    db.addUniqueEvent(Event());
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

class taskDetails extends StatelessWidget {
  final String name;
  final String description;
  final String location;
  taskDetails(this.name, this.description, this.location, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Description: " + description),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Location: " + location),
            ),
          ],
        ));
  }
}
