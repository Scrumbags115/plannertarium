import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/eventView.dart';
import 'dart:async';
import 'package:planner/view/weekView.dart';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:planner/view/monthlyTaskView.dart';

class taskView extends StatefulWidget {
  const taskView({super.key});

  @override
  _taskViewState createState() => _taskViewState();
}

class _taskViewState extends State<taskView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  DatabaseService db = DatabaseService();
  List<Task> todayTasks = [];
  bool forEvents = false;
  @override
  void initState() {
    super.initState();
    fetchTodayTasks();
  }

  void fetchTodayTasks() async {
    DateTime today = DateTime.now();
    DateTime dateStart = DateTime(today.year, today.month, today.day);
    DateTime dateEnd = dateStart.add(const Duration(days: 1));
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;
    (activeMap, delayedMap, completedMap) =
        await db.getTaskMaps(dateStart, dateEnd);

    todayTasks = [
      ...?activeMap[dateStart],
      ...?delayedMap[dateStart],
      ...?completedMap[dateStart]
    ];

    setState(() {});
    print(todayTasks);
  }

  Future<Task?> addButtonForm(BuildContext context) async {
    DatabaseService db = DatabaseService();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController colorController = TextEditingController();
    TextEditingController tagController = TextEditingController();
    TextEditingController recRulesController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();
    Completer<Task?> completer = Completer<Task?>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              // TextField(
              //   controller: tagController,
              //   decoration: InputDecoration(labelText: 'Tag'),
              // ),
              // TextField(
              //   controller: recRulesController,
              //   decoration: InputDecoration(labelText: 'Recurrence Rules'),
              // ),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(null); // Complete with null if canceled
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String name = nameController.text;
                String description = descriptionController.text;

                Task newTask = Task(
                    name: name,
                    description: description,
                    timeStart: DateTime.now());

                db.setTask(newTask);

                // Complete with the new task
                completer.complete(newTask);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Return the Future that completes with the new task
    return completer.future;
  }

  void showSearchBar(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Tasks'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Search'),
              onPressed: () async {
                String searchQuery = searchController.text;
                List<Task> searchTask = await db.getTasksOfName(searchQuery);

                if (searchTask != null) {
                  print('i am here');
                  _showTaskDetailsDialog(searchTask);
                } else {
                  print('maybe');
                  _showTaskNotFoundDialog();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showTaskDetailsDialog(List<Task> tasks) {
    showDialog(
      context: scaffoldKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Task Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tasks.map((task) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Task ID: ${task.id}'),
                  Text('Name: ${task.name}'),
                  Text('Description: ${task.description}'),
                  const Divider(),
                ],
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTaskNotFoundDialog() {
    showDialog(
      context: scaffoldKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Task Not Found'),
          content: const Text('The task with ID was not found.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu,color: Colors.black),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Task',
          style: TextStyle(
            color: Colors.black,
          ),
          ),

        actions: <Widget>[
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
                if (forEvents) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const weekView(),
                    ),
                  );
                }
              }),
          IconButton(
            icon: const Icon(Icons.search,color: Colors.black,),
            onPressed: () {
              showSearchBar(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                accountName: Text(
                  "Cheng Wai",
                  style: TextStyle(fontSize: 18),
                ),
                accountEmail: Text("cchong10@ucsc.edu"),
                currentAccountPictureSize: Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 137, 192, 255),
                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 30.0, color: Colors.blue),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(' My Profile '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text(' Go Premium '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text(' Settings '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LogOut'),
              onTap: () {
                // Navigator.pop(context);
                // fetchTodayTasks();
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          print('swipe detected');
          if (details.primaryVelocity! < 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => WeeklyTaskView(),
            ));
          }
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: todayTasks.length,
                itemBuilder: (context, index) {
                  Task task = todayTasks[index];
                  return TaskCard(task: task);
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ClipOval(
                child: ElevatedButton(
                  onPressed: () async {
                    Task? newTask = await addButtonForm(context);

                    if (newTask != null) {
                      setState(() {
                        todayTasks.add(newTask);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(75, 75),
                  ),
                  child: const Icon(Icons.add_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  DatabaseService db = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            setState(() {
              widget.task.moveToNextDay();
              db.setTask(widget.task);
              print('move to next day completed');
            });
          } else if (direction == DismissDirection.endToStart) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content:
                      const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        db.deleteTask(widget.task);
                        print('swipe right!');
                        Navigator.of(context).pop();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          }
        },
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerLeft,
          child: const Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white70, // Change the color to white gray
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            leading: InkWell(
              onTap: () {
                setState(() {
                  widget.task.completed = !widget.task.completed;
                  db.setTask(widget.task);
                });
              },
              child: CircleAvatar(
                backgroundColor:
                    widget.task.completed ? Colors.green : Colors.blue,
                child: widget.task.completed
                    ? const Icon(Icons.check, color: Colors.white)
                    : const Icon(Icons.circle, color: Colors.blue),
              ),
            ),
            title: Text(widget.task.name),
            subtitle: Text(widget.task.description),
          ),
        ),
      ),
    );
  }

  void _showDetailPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Task Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${widget.task.name}'),
              Text('Description: ${widget.task.description}'),
              Text(
                'Time: ${widget.task.timeStart}- ${widget.task.timeDue}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                // Wait for the _showEditPopup to complete and get the edited task
                Task? editedTask = await _showEditPopup(context);
                Navigator.of(context).pop();
                // Update the state only if the user submitted changes
                if (editedTask != null) {
                  setState(() {});
                }
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<Task?> _showEditPopup(BuildContext context) async {
    DatabaseService db = DatabaseService();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController colorController = TextEditingController();
    TextEditingController tagController = TextEditingController();
    TextEditingController recRulesController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();

    Completer<Task?> completer = Completer<Task?>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              // TextField(
              //   controller: tagController,
              //   decoration: InputDecoration(labelText: 'Tag'),
              // ),
              // TextField(
              //   controller: recRulesController,
              //   decoration: InputDecoration(labelText: 'Recurrence Rules'),
              // ),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(null);
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String name = nameController.text;
                String description = descriptionController.text;
                String location = locationController.text;
                String color = colorController.text;
                String tag = tagController.text;
                //String recRules = recRulesController.text;
                //String dueDate = dueDateController.text;

                widget.task.name = name;
                widget.task.description = description;
                widget.task.location = location;
                widget.task.color = color;
                widget.task.color = tag;
                //widget.task.recurrenceRules = recRules;

                db.setTask(widget.task);

                completer.complete(widget.task);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Return the Future that completes with the edited task
    return completer.future;
  }
}
