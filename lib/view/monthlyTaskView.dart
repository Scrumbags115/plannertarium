import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/view/taskView.dart';
import 'package:planner/common/time_management.dart';

class MonthlyTaskView extends StatefulWidget {
  @override
  _MonthlyTaskViewState createState() => _MonthlyTaskViewState();
}

class _MonthlyTaskViewState extends State<MonthlyTaskView> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DatabaseService db = DatabaseService();
  List<Task> todayTasks = [];
  final PageController _pageController = PageController();
  Map<DateTime, List<Task>> active = {};

  @override
  void initState() {
    super.initState();
    fetchMonthlyTasks(DateTime.now());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

// Use this function when you're setting and getting tasks from the active map
  void fetchMonthlyTasks(DateTime selectedDate) async {
    DateTime dateStart = getDateOnly(selectedDate);
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;
    (activeMap, delayedMap, completedMap) =
        await db.getTaskMapsMonth(dateStart);

    active = activeMap.map((key, value) => MapEntry(
        getDateOnly(key), value)); // Use getDateOnly when setting tasks in the active map
    todayTasks = active[getDateOnly(selectedDate)] ??
        []; // Use getDateOnly when getting tasks from the active map

    setState(() {});
    print(todayTasks);
  }

  void fetchTodayTasks(DateTime selectedDate) async {
    List<Task> activeList, delayedList, completedList;
      (activeList, delayedList, completedList) =
        await db.getTaskMapsDay(selectedDate);

    // print(
    //     'Active tasks from DB: $activeMap'); // Print the tasks fetched from the database

    // print('delayed task from DB: $delayedMap');
    // print('completed task from DB: $completedMap');

    //active = activeMap;
    todayTasks = [
      ...activeList,
      ...delayedList,
      ...completedList
    ];

    // print(
    //     'Active tasks after insertion: $active'); // Print the active map after inserting the tasks

    setState(() {});
    print('todayTasks: $todayTasks');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly View'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2130, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  fetchTodayTasks(selectedDay);
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              var taskForDay = active[getDateOnly(day)] ?? [];
              print('TDate:$day, Task:$taskForDay');
              return taskForDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, tasks) {
                //print("Date: $date, Tasks: $tasks");
                if (tasks.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todayTasks.length,
              itemBuilder: (context, index) {
                Task task = todayTasks[index];
                return TaskCard(task: task);
              },
            ),
          ),
        ],
      ),
    );
  }
}
