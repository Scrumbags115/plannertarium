import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/localTaskDatabase.dart';
import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/dailyTaskView.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:planner/view/taskCard.dart';

class WeeklyTaskView extends StatefulWidget {
  late DateTime selectedDay;
  WeeklyTaskView({super.key, DateTime? dateInWeek}) {
    selectedDay = getDateOnly(dateInWeek ?? DateTime.now());
  }
  @override
  WeeklyTaskViewState createState() => WeeklyTaskViewState();
}

class WeeklyTaskViewState extends State<WeeklyTaskView> {
  final DatabaseService _db = DatabaseService();
  late LocalTaskDatabase localDB;
  late DateTime today;

  /// Initializes the state of the widget
  @override
  void initState() {
    today = widget.selectedDay;
    localDB = LocalTaskDatabase();
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget.
  void asyncInitState() async {
    await setData();
    setState(() {});
  }

  /// Asynchronously fetches tasks for the current week
  Future<void> setData() async {
    DateTime monday = mostRecentMonday(today);
    localDB.setFromTuple(await _db.getTaskMapsWeek(monday));
  }

  void toggleCompleted(Task task) {
    DateTime monday = mostRecentMonday(today);
    localDB.toggleCompleted(task, monday);
    setState(() {
      generateScreen();
    });
  }

  void moveDelayedTask(Task task, DateTime oldTaskDate) async {
    localDB.moveDelayedTask(task, oldTaskDate);
    setState(() {
      generateScreen();
    });
  }

  void deleteTask(Task task) {
    DateTime startOfWeek = mostRecentMonday(today);
    DateTime deletionStart =
        task.timeStart.isBefore(startOfWeek) ? startOfWeek : task.timeStart;
    localDB.deleteTask(task, deletionStart);
    setState(() {
      generateScreen();
    });
  }

  /// Asynchronously transition to new WeeklyTaskView screen
  /// TODO: use something beside navigator to avoid the transition animation
  void loadWeek(DateTime newDateInWeek) async {
    resetView(newDateInWeek);
  }

  /// Asynchronously loads tasks for the previous week and generates the screen
  void loadPreviousWeek() async {
    loadWeek(getDateOnly(today, offsetDays: -7));
  }

  /// Asynchronously loads tasks for the next week and generates the screen
  void loadNextWeek() async {
    loadWeek(getDateOnly(today, offsetDays: 7));
  }

  Future<void> resetView(DateTime? selectedDate) async {
    if (selectedDate == null) {
      return;
    }

    today = selectedDate;
    await setData();
    setState(() {
      generateScreen();
    });
  }

  /// A function that generates the screen for the next 7 days
  List<Widget> generateScreen() {
    List<Widget> dayWidgets = [];
    DateTime monday = mostRecentMonday(today);
    var dateFormatter = DateFormat('EE').format;

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = getDateOnly(monday, offsetDays: i);
      List<Task> tasksForDay = localDB.getTasksForDate(currentDate);
      print(tasksForDay);

      dayWidgets.add(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '${dateFormatter(currentDate)} ${currentDate.month}/${currentDate.day}',
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
                  builder: (context) => MonthlyTaskView(dayOfMonth: today),
                ));
              }
              if (details.primaryVelocity! > 0) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DailyTaskView(),
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
