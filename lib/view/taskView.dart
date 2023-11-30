import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'dart:async';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:planner/view/dayView.dart';
import 'package:intl/intl.dart';
import 'package:planner/view/taskCard.dart';

class taskView extends StatefulWidget {
  const taskView({super.key});

  @override
  taskViewState createState() => taskViewState();
}

class taskViewState extends State<taskView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  DatabaseService db = DatabaseService();

  List<Task> todayTasks = [];
  List<Task> selectedDateTasks = [];
  List<Task> todayDelayedTasks = [];

  DateTime today = DateTime.now();
  bool forEvents = false;

  @override
  /// Initializes the state of the widget.
  void initState() {
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget.
  void asyncInitState() async {
    todayTasks = await db.fetchTodayTasks(DateTime.now());
    setState(() {});
  }

  ///A DatePicker function to prompt a calendar
  ///Returns a selectedDate if chosen, defaulted to today if no selectedDate
  Future<DateTime?> datePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      return selectedDate;
    }
    return today;
  }

  /// A void function that asynchronously selects a date and fetches tasks for that date.
  Future<void> selectDate() async {
    DateTime selectedDate = await datePicker() ?? today;
    List<Task> newTasks = await db.fetchTodayTasks(selectedDate);

    setState(() {
      today = selectedDate;
      todayTasks = newTasks;
    });
  }

  ///A function that asynchronously shows a dialog for adding a new task.
  Future<Task?> addButtonForm(BuildContext context) async {
    DatabaseService db = DatabaseService();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController tagController = TextEditingController();
    DateTime? dueDate;
    DateTime? startTime = DateTime.now();
    Completer<Task?> completer = Completer<Task?>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: SizedBox(
              height: (MediaQuery.of(context).size.height * 0.7), 
              width: (MediaQuery.of(context).size.width * 0.8), 
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
                    controller: tagController,
                    decoration: const InputDecoration(labelText: 'Tag'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.wallet),
                        onPressed: () async {
                          startTime = await datePicker();
                          setState(() {});
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
                completer.complete(null); 
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
                completer.complete(newTask);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return completer.future;
  }
  
  ///A void function that shows a dialog with a search bar to search for tasks.
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
                showTaskDetailsDialog(searchQuery, searchTask);
              },
            ),
          ],
        );
      },
    );
  }

  ///A void function that searches in a query and a list of tasks to query from
  ///Returns a list of tasks with informations of each tasks
  void showTaskDetailsDialog(String searchQuery, List<Task> tasks) {
    showDialog(
      context: scaffoldKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Results for "$searchQuery"'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tasks.map((task) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${task.completed ? "✅" : "❌"} ${task.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('  ${task.description}'),
                    Text(
                        '  Currently on: ${getDateAsString(task.timeCurrent)}'),
                    Text(
                        '  Date created: ${getDateAsString(task.timeCreated)}'),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
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

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )),
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
                            builder: (context) => SingleDay(today),
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

              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
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
