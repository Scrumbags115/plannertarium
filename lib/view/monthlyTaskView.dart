import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/view/taskView.dart';

class MonthlyTaskView extends StatefulWidget {
  const MonthlyTaskView({super.key});

  @override
  _MonthlyTaskViewState createState() => _MonthlyTaskViewState();
}

class _MonthlyTaskViewState extends State<MonthlyTaskView> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DatabaseService db = DatabaseService();
  List<Task> todayTasks = [];

  // Add a PageController for handling page navigation
   PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Add a listener to the PageController to update the focusedDay
    _pageController.addListener(() {
      setState(() {
        _focusedDay = _pageController.page == 0
            ? _focusedDay.subtract(Duration(days: 30))
            : _focusedDay.add(Duration(days: 30));
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool hasTasks(
      DateTime date,
      Map<DateTime, List<Task>> activeMap,
      Map<DateTime, List<Task>> delayedMap,
      Map<DateTime, List<Task>> completedMap) {
    List<Task> tasks = [
      ...?activeMap[date],
      ...?delayedMap[date],
      ...?completedMap[date]
    ];
    return tasks.isNotEmpty;
  }

  // This function returns a new DateTime object with only year, month, and day
  DateTime _toDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

// Use this function when you're setting and getting tasks from the active map
  void fetchMonthlyTasks(DateTime selectedDate) async {
    DateTime dateStart = _toDay(selectedDate);
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;
    (activeMap, delayedMap, completedMap) =
        await db.getTaskMapsMonth(dateStart);

    active = activeMap.map((key, value) => MapEntry(
        _toDay(key), value)); // Use _toDay when setting tasks in the active map
    todayTasks = active[_toDay(selectedDate)] ??
        []; // Use _toDay when getting tasks from the active map

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
            firstDay: DateTime(DateTime.now().year, DateTime.now().month, 1),
            lastDay: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
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
              var taskForDay = active[_toDay(day)] ?? [];
              print('TDate:$day, Task:$taskForDay');
              return taskForDay;
            },
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, date, events) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent, // No color for today
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
            headerStyle: HeaderStyle(
              titleCentered: true, // Center the title
              formatButtonVisible: false, // Hide the format button
              leftChevronIcon: GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                child: Icon(Icons.arrow_back),
              ), // Set custom left chevron icon
              rightChevronIcon: GestureDetector(
                onTap: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                child: Icon(Icons.arrow_forward),
              ), // Set custom right chevron icon
            ),
          ),
          SizedBox(
            height: 16,
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
