import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/taskView.dart';

class WeeklyTaskView extends StatefulWidget {
  const WeeklyTaskView({Key? key}) : super(key: key);

  @override
  _WeeklyTaskViewState createState() => _WeeklyTaskViewState();
}

class _WeeklyTaskViewState extends State<WeeklyTaskView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DatabaseService _db = DatabaseService();
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
    DateTime today = DateTime.now();
    DateTime start = DateTime(today.year, today.month, today.day);
    DateTime end = start.add(Duration(days: 7));

    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;

    // Fetch task maps for the specified week
    (activeMap, delayedMap, completedMap) = await _db.getTaskMaps(start, end);

    List<Task> allTasks = [
      ...?activeMap[start],
      ...?delayedMap[start],
      ...?completedMap[start],
    ];

    print('All tasks for the week: $allTasks');

    return allTasks;
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = today.add(Duration(days: i));
      DateTime currentDay =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      // Use a Set to store unique tasks for each day
      Set<Task> uniqueTasksForDay = Set<Task>();

      // Filter tasks for the current day and add them to the Set
      _allTasks.where((task) {
        DateTime taskDay = DateTime(task.timeCurrent.year,
            task.timeCurrent.month, task.timeCurrent.day);
        return !taskDay.isBefore(currentDay) && !taskDay.isAfter(currentDay);
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
                children: uniqueTasksForDay
                    .map((task) => TaskCard(task: task))
                    .toList(),
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
        title: Text('Your Weekly Tasks'),
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
