import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'dart:async';
import 'package:planner/view/weekView.dart';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:planner/view/dayView.dart';
import 'package:intl/intl.dart';

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
  List<Task> selectedDateTasks = [];
  DateTime today = DateTime.now();
  bool forEvents = false;
  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  void asyncInitState() async {
    todayTasks = await db.fetchTodayTasks(DateTime.now());
    setState(() {});
  }

  Future<DateTime?> datePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      return picked;
    }
    return today;
  }

  Future<void> selectDate() async {
    DateTime selectedDate = await datePicker() ?? today;
    List<Task> newTasks = await db.fetchTodayTasks(selectedDate);

    setState(() {
      today = selectedDate;
      todayTasks = newTasks;
    });
  }

  Future<Task?> addButtonForm(BuildContext context) async {
    DatabaseService db = DatabaseService();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController colorController = TextEditingController();
    TextEditingController tagController = TextEditingController();
    TextEditingController recRulesController = TextEditingController();
    DateTime? dueDate;
    DateTime? startTime = DateTime.now();
    TextEditingController dueDateController = TextEditingController();
    Completer<Task?> completer = Completer<Task?>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height *
                  0.7, // Adjust the height as needed
              width: MediaQuery.of(context).size.width *
                  0.8, // Adjust the width as needed
              child: Column(
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.wallet),
                        onPressed: () async {
                          startTime = await datePicker();
                          setState(() {});
                          print(startTime);
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        startTime != null
                            ? 'Start Time: ${DateFormat('yyyy-MM-dd').format(startTime!)}'
                            : 'No start time selected',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_month_rounded),
                        onPressed: () async {
                          dueDate = await datePicker();
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Due Time',
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  timeDue: dueDate,
                  timeStart: startTime,
                );

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
                List<Task> searchTask = await db.searchAllTask(searchQuery);
                _showTaskDetailsDialog(searchQuery, searchTask);
              },
            ),
          ],
        );
      },
    );
  }

  void _showTaskDetailsDialog(String searchQuery, List<Task> tasks) {
    showDialog(
      context: scaffoldKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Results for "$searchQuery"'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tasks.map((task) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${task.completed ? "✅" : "❌"} ${task.name}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('  ${task.description}'),
                  Text('  Currently on: ${getDateAsString(task.timeCurrent)}'),
                  Text('  Date created: ${getDateAsString(task.timeCreated)}'),
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
          icon: const Icon(Icons.calendar_month_rounded, color: Colors.black),
          onPressed: () {
            selectDate();
          },
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
                      if (forEvents) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WeekView(),
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
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
              builder: (context) => const WeeklyTaskView(),
            ));
          }
          if (details.primaryVelocity! > 0) {
            scaffoldKey.currentState?.openDrawer();
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
                  child: const Icon(
                    Icons.add_outlined,
                    color: Colors.black,
                  ),
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

  Future<DateTime?> datePicker() async {
    DateTime today = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      return today;
    }
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
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
                      // Delete the task and close the dialog
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
        color: const Color.fromARGB(
            255, 255, 153, 0), // Swipe right background color
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.access_time,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red, // Swipe left background color
        alignment: Alignment.centerRight,
        child: const Icon(
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
    String formattedDate = widget.task.timeDue != null
        ? DateFormat('yyyy-MM-dd').format(widget.task.timeDue!)
        : ' ';
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
                'Time: ${DateFormat('yyyy-MM-dd').format(widget.task.timeStart)}- $formattedDate',
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
    DateTime? dueDate;
    DateTime? startTime = DateTime.now();
    TextEditingController dueDateController = TextEditingController();
    Completer<Task?> completer = Completer<Task?>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height *
                  0.7, // Adjust the height as needed
              width: MediaQuery.of(context).size.width *
                  0.8, // Adjust the width as needed
              child: Column(
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.wallet),
                        onPressed: () async {
                          startTime = await datePicker();
                          setState(() {});
                          print(startTime);
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        startTime != null
                            ? 'Start Time: ${DateFormat('yyyy-MM-dd').format(startTime!)}'
                            : 'No start time selected',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_month_rounded),
                        onPressed: () async {
                          dueDate = await datePicker();
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Due Time',
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
