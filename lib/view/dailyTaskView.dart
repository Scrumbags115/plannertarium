import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/loginView.dart';
import 'dart:async';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:planner/view/taskCard.dart';

class TaskView extends StatefulWidget {
  late DateTime selectedDay;
  TaskView({super.key, DateTime? dayOfDailyView}) {
    selectedDay = dayOfDailyView ?? DateTime.now();
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
    var taskMaps = await db.getTaskMapsDay(widget.selectedDay);
    active = taskMaps.$1;
    delay = taskMaps.$2;
    complete = taskMaps.$3;

    todayTasks = active + delay + complete;
    setState(() {});
  }

  /// Dummy function called by taskCard, does not need implementation for daily view
  void toggleCompleted(Task task) {}

  /// A void function that takes a date and asynchronously fetches tasks for that date.
  Future<void> resetView(DateTime? selectedDate) async {
    if (selectedDate == null) {
      return;
    }

    widget.selectedDay = selectedDate;
    var taskMaps = await db.getTaskMapsDay(selectedDate);
    active = taskMaps.$1;
    delay = taskMaps.$2;
    complete = taskMaps.$3;

    setState(() {
      today = selectedDate;
      todayTasks = active + delay + complete;
      getTodayTaskList();
    });
  }

  void moveDelayedTask(Task task, DateTime oldDate) async {
    active.remove(task);
    delay.add(task);
    todayTasks = active + delay + complete;
    setState(() {
      getTodayTaskList();
    });
  }

  void deleteTask(Task task) {
    active.remove(task);
    delay.remove(task);
    complete.remove(task);
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
        return TaskCard(
            task: task, state: this, dateOfCard: widget.selectedDay);
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