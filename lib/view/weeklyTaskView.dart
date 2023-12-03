import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
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
  Map<DateTime, List<Task>> _active = {};
  Map<DateTime, List<Task>> _complete = {};
  Map<DateTime, List<Task>> _delay = {};

  @override

  /// Initializes the state of the widget
  void initState() {
    super.initState();
    setData();
  }

  /// Asynchronously fetches tasks for the current week
  Future<void> setData() async {
    var taskMaps = await _db.getTaskMapsWeek(widget.monday);
    setState(() {
      _active = taskMaps.$1;
      _complete = taskMaps.$2;
      _delay = taskMaps.$3;
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

  /// A DatePicker function to prompt a calendar
  /// Returns a selectedDate if chosen, defaulted to today if no selectedDate
  Future<void> datePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.monday,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      // setState(() {
      //   widget.monday = mostRecentMonday(selectedDate);
      // });
      // await setData();
      loadWeek(getDateOnly(selectedDate));
    }
  }

  ///A function that generates the screen for the next 7 days
  List<Widget> generateScreen() {
    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = getDateOnly(widget.monday, offsetDays: i);
      List<Task> tasksForDay = (_active[currentDate] ?? []) +
          (_complete[currentDate] ?? []) +
          (_delay[currentDate] ?? []);

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
                      TaskCard(task: task),
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
                  builder: (context) => MonthlyTaskView(),
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
