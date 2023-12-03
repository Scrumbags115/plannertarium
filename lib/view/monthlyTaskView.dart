import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/view/taskCard.dart';

class MonthlyTaskView extends StatefulWidget {
  const MonthlyTaskView({super.key});
  @override
  MonthlyTaskViewState createState() => MonthlyTaskViewState();
}

class MonthlyTaskViewState extends State<MonthlyTaskView> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DatabaseService db = DatabaseService();
  List<Task> todayTasks = [];
  final PageController _pageController = PageController();
  Map<DateTime, List<Task>> active = {};
  DateTime today = getDateOnly(DateTime.now());
  @override

  /// Initializes the state of the widget
  void initState() {
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget
  void asyncInitState() async {
    final List<Task> newTodayTasks;
    final Map<DateTime, List<Task>> newMonthlyTasks;
    (newTodayTasks, newMonthlyTasks) =
        await db.fetchMonthlyTasks(DateTime.now());
    todayTasks = newTodayTasks;
    active = newMonthlyTasks;
    setState(() {});
    print('monthly: $active');
  }

  @override

  /// Disposes of the resources used by the widget
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>  WeeklyTaskView(),
            ));
          }
        },
        child: Scaffold(
          appBar: getTopBar(Task, "monthly", context, this),
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
                    final newTodayTasks = await db.fetchTodayTasks(selectedDay);
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      todayTasks = newTodayTasks;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  today = getDateOnly(focusedDay);
                },
                eventLoader: (day) {
                  var taskForDay = active[getDateOnly(day)] ?? [];
                  return taskForDay;
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, tasks) {
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
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, 0, 20, 20), // Adjust the value as needed
                  child: ClipOval(
                    child: ElevatedButton(
                      onPressed: () async {
                        Task? newTask = await addButtonForm(context, this);
                        if (newTask != null) {
                          setState(() {
                            DateTime newTaskDateStart = newTask.timeStart;
                            active[newTaskDateStart] = [
                              ...active[newTaskDateStart] ?? [],
                              newTask
                            ];
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
              )
            ],
          ),
        ));
  }
}
