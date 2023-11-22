import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/view/taskView.dart';

class MonthlyTaskView extends StatefulWidget {
  @override
  _MonthlyTaskViewState createState() => _MonthlyTaskViewState();
}

class _MonthlyTaskViewState extends State<MonthlyTaskView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
            ? _focusedDay = getDateOnly(_focusedDay, offsetMonths: -1)
            : _focusedDay = getDateOnly(_focusedDay, offsetMonths: 1);
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the PageController to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  void fetchTodayTasks(DateTime selectedDate) async {
    List<Task> activeList, delayedList, completedList;
    (activeList, delayedList, completedList) =
        await db.getTaskMapsDay(selectedDate);

    todayTasks = [
      ...activeList,
      ...delayedList,
      ...completedList
    ];

    setState(() {});
    print(todayTasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly View'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: getMonthAsDateTime(DateTime.now()),
            lastDay: getNextMonthAsDateTime(DateTime.now()),
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
                });

                // Call the fetchTodayTasks function without await
                fetchTodayTasks(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // Update the focusedDay when navigating to previous/next months
              setState(() {
                _focusedDay = focusedDay;
              });
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
