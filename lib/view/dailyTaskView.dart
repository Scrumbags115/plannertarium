import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/localTaskDatabase.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/loginView.dart';
import 'dart:async';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:planner/view/taskCard.dart';

class DailyTaskView extends StatefulWidget {
  late final DateTime selectedDay;
  DailyTaskView({DateTime? dayOfDailyView}) {
    selectedDay = getDateOnly(dayOfDailyView ?? DateTime.now());
  }
  @override
  TaskViewState createState() => TaskViewState();
}

class TaskViewState extends State<DailyTaskView> {
  DatabaseService db = DatabaseService();
  late LocalTaskDatabase localDB;
  late DateTime today;

  @override

  /// Initializes the state of the widget.
  void initState() {
    today = widget.selectedDay;
    localDB = LocalTaskDatabase();
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget.
  void asyncInitState() async {
    localDB.setFromTuple(await db.getTaskMapsDay(today));

    setState(() {});
  }

  /// Dummy function called by taskCard, does not need implementation for daily view
  void toggleCompleted(Task task) {}

  /// A void function that takes a date and asynchronously fetches tasks for that date.
  Future<void> resetView(DateTime? selectedDate) async {
    if (selectedDate == null) {
      return;
    }

    localDB.setFromTuple(await db.getTaskMapsDay(selectedDate));

    setState(() {
      today = getDateOnly(selectedDate);
      getTodayTaskList();
    });
  }

  void moveDelayedTask(Task task, DateTime oldDate) async {
    localDB.moveDelayedTask(task, oldDate);
    setState(() {
      getTodayTaskList();
    });
  }

  void deleteTask(Task task) {
    localDB.deleteTask(task, today);
    setState(() {
      getTodayTaskList();
    });
  }

  ListView getTodayTaskList() {
    print(localDB.getTasksForDate(today));
    return ListView.builder(
      // Must use this format for calls to setState(_active) or similar to update view
      itemCount: localDB.getTasksForDate(today).length,
      itemBuilder: (context, index) {
        Task task = localDB.getTasksForDate(today)[index];
        return TaskCard(task: task, state: this, dateOfCard: today);
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
                      localDB.addNewTask(newTask);
                      setState(() {
                        getTodayTaskList();
                      });
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
