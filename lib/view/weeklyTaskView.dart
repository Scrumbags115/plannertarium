import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/dailyTaskView.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:planner/view/taskCard.dart';

class WeeklyTaskView extends StatefulWidget {
  late DateTime monday;
  late DateTime currentDate;
  WeeklyTaskView({super.key, DateTime? dateInWeek}) {
    currentDate = getDateOnly(dateInWeek ?? DateTime.now());
    monday = mostRecentMonday(dateInWeek ?? DateTime.now());
  }

  @override
  WeeklyTaskViewState createState() => WeeklyTaskViewState();
}

class WeeklyTaskViewState extends State<WeeklyTaskView> {
  final DatabaseService _db = DatabaseService();
  DateTime today = DateTime.now();
  Map<DateTime, List<Task>> active = {};
  Map<DateTime, List<Task>> complete = {};
  Map<DateTime, List<Task>> delay = {};

  /// Initializes the state of the widget
  @override
  void initState() {
    super.initState();
    setData();
  }

  /// Asynchronously fetches tasks for the current week
  Future<void> setData() async {
    var taskMaps = await _db.getTaskMapsWeek(widget.monday);
    setState(() {
      active = taskMaps.$1;
      complete = taskMaps.$2;
      delay = taskMaps.$3;
    });
  }

  void toggleCompleted(Task task) {
    for (int i = 0; i < 7; i++) {
      // get the date of the current day
      DateTime curr = getDateOnly(widget.monday, offsetDays: i);

      // if the task was just completed
      if (task.completed) {
        // and if the task was active
        if (active[curr]!.contains(task)) {
          // then remove it from active and add it to complete
          active[curr]!.remove(task);
          complete[curr]!.add(task);
        }

        // or if the task was delayed
        if (delay[curr]!.contains(task)) {
          // then remove it from delayed and add it to complete
          delay[curr]!.remove(task);
          complete[curr]!.add(task);
        }
        // if the task was just uncompleted
      } else {
        // and if the task was complete
        if (complete[curr]!.contains(task)) {
          // then remove it from complete and add it to active
          complete[curr]!.remove(task);
          // if the task ws delayed
          if (curr.isBefore(task.timeCurrent)) {
            // then add it to the delayed list
            delay[curr]!.add(task);
          }

          if (curr.isAtSameMomentAs(task.timeCurrent)) {
            // otherwise add it to the active list
            active[curr]!.add(task);
          }
        }
      }
    }
    // then update the screen
    setState(() {
      generateScreen();
    });
  }

  // void toggleCompleted(Task task) {
  //   for (int i = 0; i < 7; i++) {
  //     DateTime curr = getDateOnly(widget.monday, offsetDays: i);

  //     // if a task was just completed
  //     if (task.completed) {
  //       // and if the task was active
  //       if (active[curr]!.contains(task)) {
  //         active[curr]!.remove(task);
  //         complete[curr]!.add(task);
  //       }
  //     }
  //   }
  // }

  void moveDelayedTask(Task task, DateTime oldTaskDate) async {
    DateTime newTaskDate = task.timeCurrent;
    active[oldTaskDate]!.remove(task);
    for (int i = 0; i < daysBetween(oldTaskDate, newTaskDate); i++) {
      DateTime dateToDelay = getDateOnly(oldTaskDate, offsetDays: i);
      if (delay[dateToDelay] == null) {
        delay[dateToDelay] = [];
      }
      delay[dateToDelay]!.add(task);
    }
    if (active[newTaskDate] == null) {
      active[newTaskDate] = [];
    }
    active[newTaskDate]!.add(task);
    setState(() {
      generateScreen();
    });
  }

  void deleteTask(Task task) {
    DateTime deletionStart =
        task.timeStart.isBefore(widget.monday) ? widget.monday : task.timeStart;
    DateTime deletionEnd = task.timeCurrent;
    int daysToDelete = daysBetween(deletionStart, deletionEnd) + 1;

    for (int i = 0; i < daysToDelete; i++) {
      DateTime toDeleteTaskFrom = getDateOnly(deletionStart, offsetDays: i);
      active[toDeleteTaskFrom]!.remove(task);
      complete[toDeleteTaskFrom]!.remove(task);
      delay[toDeleteTaskFrom]!.remove(task);
    }

    setState(() {
      generateScreen();
    });
  }

  /// Asynchronously transition to new WeeklyTaskView screen
  void loadWeek(DateTime newDateInWeek) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WeeklyTaskView(dateInWeek: newDateInWeek),
      ),
    );
  }

  /// Asynchronously loads tasks for the previous week and generates the screen
  void loadPreviousWeek() async {
    loadWeek(getDateOnly(widget.currentDate, offsetDays: -7));
  }

  /// Asynchronously loads tasks for the next week and generates the screen
  void loadNextWeek() async {
    loadWeek(getDateOnly(widget.currentDate, offsetDays: 7));
  }

  void resetView(DateTime? selectedDate) async {
    if (selectedDate == null) {
      return;
    }

    setState(() {
      today = selectedDate;
    });
    await setData();
    generateScreen();
  }

  ///A function that generates the screen for the next 7 days
  List<Widget> generateScreen() {
    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = getDateOnly(widget.monday, offsetDays: i);
      List<Task> tasksForDay = (active[currentDate] ?? []) +
          (complete[currentDate] ?? []) +
          (delay[currentDate] ?? []);

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
            if (tasksForDay.isNotEmpty)
              Column(
                children: tasksForDay.map((task) {
                  return Column(
                    children: [
                      TaskCard(
                          task: task, dateOfCard: currentDate, state: this),
                    ],
                  );
                }).toList(),
              ),
            if (tasksForDay.isEmpty)
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
                  builder: (context) =>
                      MonthlyTaskView(dayOfMonth: widget.currentDate),
                ));
              }
              if (details.primaryVelocity! > 0) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TaskView(),
                ));
              }
            },
            child: ListView(
              children: generateScreen(),
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
                      setData();
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
