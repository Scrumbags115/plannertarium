import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/view/taskView.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/view/monthView.dart';
import 'package:planner/view/taskCard.dart';

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
    asyncInitState();
  }

  void asyncInitState() async {
    final List<Task> newTodayTasks;
    final Map<DateTime, List<Task>> newMonthlyTasks;
    (newTodayTasks, newMonthlyTasks) =
        await db.fetchMonthlyTasks(DateTime.now());
    todayTasks = newTodayTasks;
    active = newMonthlyTasks;
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool forEvents = false;
    return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const WeeklyTaskView(),
            ));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                                builder: (context) => const MonthView(),
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
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () {
                  //showSearchBar(context);
                },
              ),
            ],
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
                onDaySelected: (selectedDay, focusedDay) async {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    final _newTodayTasks =
                        await db.fetchTodayTasks(selectedDay);
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      todayTasks = _newTodayTasks;
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
        ));
  }
}
