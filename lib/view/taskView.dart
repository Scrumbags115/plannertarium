import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'dart:async';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:intl/intl.dart';
import 'package:planner/view/taskCard.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  TaskViewState createState() => TaskViewState();
}

class TaskViewState extends State<TaskView> {
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
      appBar: getTopBar(Task, "daily", context, this),
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
              onTap: () {},
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
            //getAddTaskButton(this, context),
           Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0, 0, 20, 20), // Adjust the value as needed
                child: ClipOval(
                  child: ElevatedButton(
                    onPressed: () async {
                      Task? newTask = await addButtonForm(context,this);
                      if (newTask != null) {
                        setState(() {
                          todayTasks.add(newTask);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: const Size(75, 75),
                    ),
                    child: const Icon(
                      Icons.add_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
