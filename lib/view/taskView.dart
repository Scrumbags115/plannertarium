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
            getAddTaskButton(this, context),
          ],
        ),
      ),
    );
  }
}
