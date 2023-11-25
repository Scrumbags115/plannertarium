import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/taskView.dart';

class WeeklyTaskView extends StatefulWidget {
  const WeeklyTaskView({super.key});

  @override
  _WeeklyTaskViewState createState() => _WeeklyTaskViewState();
}

class _WeeklyTaskViewState extends State<WeeklyTaskView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _db = DatabaseService();
  List<Task> _allTasks = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    List<Task> tasks = await fetchWeeklyTask();
    setState(() {
      _allTasks = tasks;
    });
  }

  Future<List<Task>> fetchWeeklyTask() async {
    DateTime today = getDateOnly(DateTime.now());
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;

    // Fetch task maps for the specified week
    (activeMap, delayedMap, completedMap) = await _db.getTaskMapsWeek(today);

    List<Task> allTasks = [
      ...?activeMap[today],
      ...?delayedMap[today],
      ...?completedMap[today],
    ];

    print('All tasks for the week: $allTasks');

    return allTasks;
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (uniqueTasksForDay.isNotEmpty)
              Column(
                children: uniqueTasksForDay
                    .map((task) => TaskCard(task: task))
                    .toList(),
              ),
            if (uniqueTasksForDay.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
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
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => fetchData(), // Function to call when refreshed
        child: ListView(
          children: dayWidgets,
        ),
      ),
    );
  }
}
