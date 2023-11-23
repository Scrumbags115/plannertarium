import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/taskView.dart';
import 'package:planner/view/monthlyTaskView.dart';

class WeeklyTaskView extends StatefulWidget {
  const WeeklyTaskView({super.key});

  @override
  _WeeklyTaskViewState createState() => _WeeklyTaskViewState();
}

class _WeeklyTaskViewState extends State<WeeklyTaskView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DatabaseService _db = DatabaseService();
  List<Task> _allTasks = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    List<Task> tasks = await _db.fetchWeeklyTask();
    setState(() {
      _allTasks = tasks;
    });
  }

  bool isTaskDueOnCurrentDay(Task task, DateTime currentDate) {
    if (task.timeDue == null) {
      return false;
    }
    return getDateOnly(task.timeDue ?? currentDate).isAtSameMomentAs(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = getDateOnly(today, offsetDays: i);

      // Use a Set to store unique tasks for each day
      Set<Task> uniqueTasksForDay = <Task>{};

      // Filter tasks for the current day and add them to the Set
      _allTasks.where((task) {
        DateTime taskDay = DateTime(task.timeCurrent.year,
            task.timeCurrent.month, task.timeCurrent.day);
        return !taskDay.isBefore(currentDate) && !taskDay.isAfter(currentDate);
      }).forEach((task) {
        uniqueTasksForDay.add(task);
      });

      dayWidgets.add(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '${currentDate.month}/${currentDate.day}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (uniqueTasksForDay.isNotEmpty)
              Column(
                children: uniqueTasksForDay.map((task) {
                  bool isDueOnCurrentDay =
                      isTaskDueOnCurrentDay(task, currentDate);
                  return Column(
                    children: [
                      TaskCard(task: task),
                      if (isDueOnCurrentDay)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Due today!',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            if (uniqueTasksForDay.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('No tasks for this day'),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Weekly Tasks'),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          print('swipe detected');
          if (details.primaryVelocity! < 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MonthlyTaskView(),
            ));
          }
        },
        child: ListView(
          children: dayWidgets,
        ),
      ),
    );
  }
}
