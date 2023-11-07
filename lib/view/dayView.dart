import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';

DatabaseService dayta = DatabaseService(uid: "userid1");

class dayView extends StatelessWidget {
  dayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: SingleDay()), //Creates one SingleDay
    );
  }
}

//The entirety of the dayView is one SingleDay
class SingleDay extends StatefulWidget {
  const SingleDay({super.key});
  @override
  State<StatefulWidget> createState() => SingleDayState();
}

class SingleDayState extends State<SingleDay> {
  Future<
      (
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>
      )> getCurrentTasks() async {
    DateTime n =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return await dayta.getTaskMaps(DateTime.now().subtract(Duration(days: 1)),
        DateTime.now().add(Duration(days: 1)));
  }

  List<Task>? currentTasks = [];
  DateTime n =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  SingleDayState() {
    getCurrentTasks().then((value) => setState(() {
          currentTasks = value.$1[n];
        }
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Card(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), "Tasks for today!"),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.generate(currentTasks!.length, (index) {
                            return Row(
                              children: [
                                SizedBox(height: 40,
                                  child: Card(color: Colors.amber,
                                    child: InkWell(
                                      splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                        /*Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => dayView()),
                                        );*/
                                      },
                                      child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), currentTasks![index].name),
                                      ),
                                    )
                                  )
                                ),
                              ],
                            );
                          })
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => createTaskPage()),
                    );
                  },
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                            child: Text("$displaynum $ampm"), //Placeholder hour
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
      return Row();
    }
  }
}

class createTaskPage extends StatelessWidget {
  const createTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Add Task')),
        body: const createTask(),
      ),
    );
  }
}

class createTask extends StatefulWidget {
  const createTask({super.key});

  @override
  State<createTask> createState() => _createTask();
}

class _createTask extends State<createTask> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
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
                return 'Please enter some text';
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
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            controller: taskDescriptionController,
            onSaved: (value) {
              taskDescriptionController.text = value!;
            },
          ),
          TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter task due date',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              controller: dueDateController,
              onSaved: (value) {
                dueDateController.text = value!;
              }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  var testtask = Task(
                      name: taskNameController.text,
                      description: taskDescriptionController.text,
                      timeDue: DateTime.parse(dueDateController.text));
                  dayta.setUserTask(testtask);
                }
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
