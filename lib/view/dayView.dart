import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';

DatabaseService dayta = DatabaseService(uid: "userid1");

//The entirety of the dayView is one SingleDay
class SingleDay extends StatefulWidget {
  final DateTime date;
  const SingleDay(this.date, {super.key});

  @override
  SingleDayState createState() => SingleDayState(date);
}

class SingleDayState extends State<SingleDay> {
  DateTime date;
  List<Task>? currentTasks = [];
  List<Task>? currentdayTasks = [];
  SingleDayState(this.date) {
    getCurrentTasks() {
      return dayta.getTaskMaps(date, date.add(const Duration(days: 1)));
    }
    getCurrentTasks().then((value) => setState(() {
          currentTasks = value.$1[date];
          //print(currentTasks);
          for (int i = 0; i < currentTasks!.length; i++) {
            if (currentTasks![i].timeDue!.isAtSameMomentAs(date) &
                currentTasks![i].timeDue!.isBefore(date.add(const Duration(days: 1)))) {
              currentdayTasks!.add(currentTasks![i]);
            }
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),"Tasks for today!"),
                        Expanded(
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(currentTasks!.length, (index) {
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
                                                          singleTask(currentTasks![index].name, currentTasks![index].description)),
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
                                                    currentdayTasks![index]
                                                        .name),
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
  final TextEditingController taskDescriptionController = TextEditingController();

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    dayta.setTask(Task(
                        name: taskNameController.text,
                        description: taskDescriptionController.text,
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

class singleTask extends StatelessWidget {
  String name;
  String description;
  singleTask(this.name, this.description, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Card(child: Text(description)));
  }
}
