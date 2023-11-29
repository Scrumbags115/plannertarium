import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/taskView.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/view/weekView.dart';

class WeeklyTaskView extends StatefulWidget {
  const WeeklyTaskView({super.key});

  @override
  _WeeklyTaskViewState createState() => _WeeklyTaskViewState();
}

class _WeeklyTaskViewState extends State<WeeklyTaskView> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _db = DatabaseService();
  List<Task> _allTasks = [];
  DateTime today = getDateOnly(DateTime.now());
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

  Future<List<Task>> fetchWeeklyTask() async {
    DateTime today = getDateOnly(DateTime.now());
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;

    // Fetch task maps for the specified week
    (activeMap, delayedMap, completedMap) = await _db.getTaskMapsWeek(today);
    Map<DateTime, List<Task>> dueTasksMap = await _db.getTasksDueWeek(today);

    List<Task> allTasks = [
      ...?activeMap[today],
      ...?delayedMap[today],
      ...?completedMap[today],
      ...?dueTasksMap[today],
    ];
    print('All tasks for the week: $allTasks');

    return allTasks;
  }

  bool isTaskDueOnCurrentDay(Task task, DateTime currentDate) {
    if (task.timeDue == null) {
      return false;
    }
    return getDateOnly(task.timeDue ?? currentDate)
        .isAtSameMomentAs(currentDate);
  }

  void loadPreviousWeek() async {
    await fetchData();
    setState(() {
      today = today.subtract(const Duration(days: 7));
      generateScreen(today);
    });
  }

  void loadNextWeek() async {
    setState(() {
      today = today.add(const Duration(days: 7));
    });
    await fetchData();
    generateScreen(today);
  }

  Future<void> datePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        today = picked;
      });
      await fetchData();
      generateScreen(today);
    }
  }

  List<Widget> generateScreen(DateTime dateStart) {
    DateTime current = dateStart;
    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      DateTime thisMostRecentMonday = mostRecentMonday(today);
      DateTime currentDate = getDateOnly(thisMostRecentMonday, offsetDays: i);

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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        const Padding(
                          padding: EdgeInsets.all(8.0),
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No tasks for this day'),
              ),
          ],
        ),
      );
    }
    return dayWidgets;
  }

  @override
  Widget build(BuildContext context) {
    bool forEvents = false;
    DateTime today = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  loadPreviousWeek();
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.calendar_month_rounded,
                    color: Colors.black),
                onPressed: () {
                  datePicker();
                },
              ),
            ),
          ],
        ),
        title: Center(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 20),
                    const Text(
                      'Tasks ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Switch(
                      // thumb color (round icon)
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
                              builder: (context) => WeekView(),
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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              //showSearchBar();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: () {
              loadNextWeek();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // print('swipe detected');
          if (details.primaryVelocity! < 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MonthlyTaskView(),
            ));
          }
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const taskView(),
            ));
          }
        },
        child: ListView(
          children: generateScreen(today),
        ),
      ),
    );
  }
}
