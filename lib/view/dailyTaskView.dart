import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/loginView.dart';
import 'dart:async';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:planner/view/taskCard.dart';

class DailyTaskView extends StatefulWidget {
  late final DateTime selectedDay;
  DailyTaskView({DateTime? dayOfDailyView}) {
    selectedDay = dayOfDailyView ?? DateTime.now();
  }
  @override
  TaskViewState createState() => TaskViewState();
}

class TaskViewState extends State<DailyTaskView> {
  DatabaseService db = DatabaseService();
  late DateTime today;
  List<Task> _active = [];
  List<Task> _delay = [];
  List<Task> _complete = [];

  @override

  /// Initializes the state of the widget.
  void initState() {
    today = widget.selectedDay;
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget.
  void asyncInitState() async {
    var taskMaps = await db.getTaskMapsDay(today);
    _active = taskMaps.$1;
    _delay = taskMaps.$2;
    _complete = taskMaps.$3;

    setState(() {});
  }

  /// Dummy function called by taskCard, does not need implementation for daily view
  void toggleCompleted(Task task) {}

  /// A void function that takes a date and asynchronously fetches tasks for that date.
  Future<void> resetView(DateTime? selectedDate) async {
    if (selectedDate == null) {
      return;
    }

    var taskMaps = await db.getTaskMapsDay(selectedDate);
    _active = taskMaps.$1;
    _delay = taskMaps.$2;
    _complete = taskMaps.$3;

    setState(() {
      today = selectedDate;
      getTodayTaskList();
    });
  }

  void moveDelayedTask(Task task, DateTime oldDate) async {
    _active.remove(task);
    _delay.add(task);
    setState(() {
      getTodayTaskList();
    });
  }

  void deleteTask(Task task) {
    _active.remove(task);
    _delay.remove(task);
    _complete.remove(task);
    setState(() {
      getTodayTaskList();
    });
  }

  ListView getTodayTaskList() {
    return ListView.builder(
      // Must use this format for calls to setState(_active) or similar to update view
      itemCount: (_active + _delay + _complete).length,
      itemBuilder: (context, index) {
        Task task = (_active + _delay + _complete)[index];
        return TaskCard(
            task: task, state: this, dateOfCard: today);
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
                          _active.add(newTask);
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
