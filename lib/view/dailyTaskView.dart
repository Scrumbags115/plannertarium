import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/loginView.dart';
import 'dart:async';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:planner/view/taskCard.dart';

class TaskView extends StatefulWidget {
  late DateTime focusedDay;
  TaskView({super.key, DateTime? dayOfDailyView}) {
    focusedDay = dayOfDailyView ?? DateTime.now();
  }
  @override
  TaskViewState createState() => TaskViewState();
}

class TaskViewState extends State<TaskView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  DatabaseService db = DatabaseService();
  DateTime today = DateTime.now();
  List<Task> active = [];
  List<Task> delay = [];
  List<Task> complete = [];

  List<Task> todayTasks = [];
  List<Task> selectedDateTasks = [];
  List<Task> todayDelayedTasks = [];
  bool forEvents = false;

  @override

  /// Initializes the state of the widget.
  void initState() {
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget.
  void asyncInitState() async {
    var taskMaps = await db.getTaskMapsDay(widget.focusedDay);
    active = taskMaps.$1;
    delay = taskMaps.$2;
    complete = taskMaps.$3;

    todayTasks = active + delay + complete;
    setState(() {});
  }

  ///A DatePicker function to prompt a calendar
  ///Returns a selectedDate if chosen, defaulted to today if no selectedDate
  Future<DateTime?> datePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.focusedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      return selectedDate;
    }
    return widget.focusedDay;
  }

  /// A void function that asynchronously selects a date and fetches tasks for that date.
  Future<void> selectDate({context}) async {
    DateTime selectedDate = await datePicker() ?? widget.focusedDay;
    List<Task> newTasks = await db.fetchTodayTasks(selectedDate);

    setState(() {
      widget.focusedDay = selectedDate;
      todayTasks = newTasks;
    });

    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TaskView(dayOfDailyView: selectedDate),
        ),
      );
    }
  }

  void moveDelayedTask(Task task, DateTime oldDate) async {
    active.remove(task);
    delay.add(task);
    todayTasks = active + delay + complete;
    setState(() {
      getTodayTaskList();
    });
  }

  ListView getTodayTaskList() {
    return ListView.builder(
      itemCount: todayTasks.length,
      itemBuilder: (context, index) {
        Task task = todayTasks[index];
        return TaskCard(task: task, state: this, dateOfCard: widget.focusedDay);
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
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  accountName: Text(
                    db.getUsername(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  accountEmail: Text(db.getEmail()),
                  currentAccountPictureSize: const Size.square(50),
                  currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(db.getPFPURL()))),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LogOut'),
              onTap: () {
                db.signOut();
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LoginView(),
                  ));
                });
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => WeeklyTaskView(),
            ));
          }
          if (details.primaryVelocity! > 0) {
            scaffoldKey.currentState?.openDrawer();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: getTodayTaskList(),
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
                      Task? newTask = await addButtonForm(context, this);
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
