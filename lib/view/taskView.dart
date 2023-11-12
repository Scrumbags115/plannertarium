import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planner/models/task.dart';
import 'package:planner/tests/task_tests.dart';
import 'dart:async';

class taskView extends StatefulWidget {
  const taskView({Key? key}) : super(key: key);

  @override
  _taskViewState createState() => _taskViewState();
}

class _taskViewState extends State<taskView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  DatabaseService db = DatabaseService(uid: "ian");
  List<Task> todayTasks = [];

  @override
  void initState() {
    super.initState();
    fetchTodayTasks();
  }

  void fetchTodayTasks() async {
    DateTime today = DateTime.now();
    DateTime dateStart = DateTime(today.year, today.month, today.day);
    DateTime dateEnd = dateStart.add(Duration(days: 1));
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;
    (activeMap, delayedMap, completedMap) =
        await db.getTaskMaps(dateStart, dateEnd);

    todayTasks = []
      ..addAll(activeMap[dateStart] ?? [])
      ..addAll(delayedMap[dateStart] ?? [])
      ..addAll(completedMap[dateStart] ?? []);

    setState(() {});
    print(todayTasks);
  }

  void _showTaskDetailsDialog(List<Task> tasks) {
    showDialog(
      context: scaffoldKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tasks.map((task) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Task ID: ${task.id}'),
                  Text('Name: ${task.name}'),
                  Text('Description: ${task.description}'),
                  Divider(),
                ],
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
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
          title: Text('Task Not Found'),
          content: Text('The task with ID was not found.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<Task?> addButtonForm(BuildContext context) async {
    DatabaseService db = DatabaseService(uid: 'ian');
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    Completer<Task?> completer = Completer<Task?>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(null); // Complete with null if canceled
              },
            ),
            TextButton(
              child: Text('Submit'),
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
          title: Text('Search Tasks'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () async {
                String searchQuery = searchController.text;
                List<Task> searchTask = await db.getTasksOfName(searchQuery);

                if (searchTask != null) {
                  _showTaskDetailsDialog(searchTask);
                } else {
                  _showTaskNotFoundDialog();
                }
              },
            ),
          ],
        );
      },
    );
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text('Task'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
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
              ), //BoxDecoration
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
                  ), //Text
                ), //circleAvatar
              ), //UserAccountDrawerHeader
            ), //DrawerHeader
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
                fetchTodayTasks();
              },
            ),
          ],
        ),
      ),
      body: Column(
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
    );
  }
}

class TaskCard extends StatefulWidget {
  final Task task;

  TaskCard({required this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  DatabaseService db = DatabaseService(uid: 'ian');
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          setState(() {
            widget.task.completed = true;
            db.setTask(widget.task);
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
                      // Delete the task and close the dialog
                      //db.deleteTask(widget.task);
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
        color: Colors.green, // Swipe right background color
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red, // Swipe left background color
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.all(1.0),
        child: InkWell(
          onTap: () {
            _showDetailPopup(context);
          },
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
                    : const Icon(Icons.circle, color: Colors.white),
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
            )
          ],
        );
      },
    );
  }
}
