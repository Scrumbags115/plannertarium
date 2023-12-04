import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/taskView.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:planner/view/taskCard.dart';

class WeeklyTaskView extends StatefulWidget {
  const WeeklyTaskView({super.key});

  @override
  WeeklyTaskViewState createState() => WeeklyTaskViewState();
}

class WeeklyTaskViewState extends State<WeeklyTaskView> {
  final DatabaseService _db = DatabaseService();
  List<Task> _allTasks = [];
  DateTime today = getDateOnly(DateTime.now());

  @override

  /// Initializes the state of the widget
  void initState() {
    super.initState();
    fetchData();
  }

  /// Asynchronously fetches tasks for the current week
  Future<void> fetchData({DateTime? weekStart}) async {
    List<Task> tasks = await _db.fetchWeeklyTask(weekStart: weekStart);
    setState(() {
      _allTasks = tasks;
    });
  }

  /// Checks if a task is due on the current day
  bool isTaskDueOnCurrentDay(Task task, DateTime currentDate) {
    if (task.timeDue == null) {
      return false;
    }
    return getDateOnly(task.timeDue ?? currentDate)
        .isAtSameMomentAs(currentDate);
  }

  /// Asynchronously loads tasks for the previous week and generates the screen
  void loadPreviousWeek() async {
    await fetchData();
    setState(() {
      today = getDateOnly(today, offsetDays: -7);
      generateScreen(today);
    });
  }

  /// Asynchronously loads tasks for the next week and generates the screen
  void loadNextWeek() async {
    setState(() {
      today = getDateOnly(today, offsetDays: 7);
    });
    await fetchData();
    generateScreen(today);
  }

  void resetView(DateTime? selectedDate) async {
    if (selectedDate == null) {
      return;
    }

    setState(() {
      today = selectedDate;
    });
    await fetchData(weekStart: selectedDate);
    generateScreen(today);
  }

  ///A function that generates the screen for the next 7 days
  List<Widget> generateScreen(DateTime dateStart) {
    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      DateTime thisMostRecentMonday = mostRecentMonday(today);
      DateTime currentDate = getDateOnly(thisMostRecentMonday, offsetDays: i);
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
    return Scaffold(
      appBar: getTopBar(Task, "weekly", context, this),
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MonthlyTaskView(),
                ));
              }
              if (details.primaryVelocity! > 0) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TaskView(),
                ));
              }
            },
            child: ListView(
              children: generateScreen(today),
            ),
          ),
          Positioned(
            bottom: 20.0, // Distance from the bottom of the screen
            right: 20.0, // Distance from the right side of the screen
            child: ClipOval(
              child: ElevatedButton(
                onPressed: () async {
                  Task? newTask = await addButtonForm(context, this);
                  if (newTask != null) {
                    setState(() {
                      _allTasks.add(newTask);
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
        ],
      ),
    );
  }
}
