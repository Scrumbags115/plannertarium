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
  late DateTime startOfMonth;
  late DateTime currentDate;
  MonthlyTaskView({super.key, required DateTime dayOfMonth}) {
    currentDate = getDateOnly(dayOfMonth);
    startOfMonth = getMonthAsDateTime(currentDate);
  }
  @override
  MonthlyTaskViewState createState() => MonthlyTaskViewState();
}

class MonthlyTaskViewState extends State<MonthlyTaskView> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = getDateOnly(DateTime.now());
  final DatabaseService _db = DatabaseService();
  List<Task> todayTasks = [];
  final PageController _pageController = PageController();
  Map<DateTime, List<Task>> _active = {};
  Map<DateTime, List<Task>> _delay = {};
  Map<DateTime, List<Task>> _complete = {};
  DateTime today = DateTime.now();

  /// Initializes the state of the widget
  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget
  void asyncInitState() async {
    await setData();
    setState(() {});
    // print('monthly: $_active');
  }

  /// Asynchronously fetches tasks for the current week
  Future<void> setData() async {
    var taskMaps = await _db.getTaskMapsMonth(getMonthAsDateTime(_selectedDay));
    setState(() {
      _active = taskMaps.$1;
      _complete = taskMaps.$2;
      _delay = taskMaps.$3;
      todayTasks = (_active[_selectedDay] ?? []) +
          (_complete[_selectedDay] ?? []) +
          (_delay[_selectedDay] ?? []);
    });
  }

  void moveDelayedTask(Task task, DateTime oldTaskDate) async {
    print("delaying $task on $_selectedDay");
    print("active: $_active");
    print("delay: $_delay");
    print("comp: $_complete");
    print("today: $todayTasks");
    DateTime newTaskDate = task.timeCurrent;
    _active[oldTaskDate]!.remove(task) ? print("removed $task") : print("failed to remove $task");
    setState(() {});
    for (int i = 0; i < daysBetween(oldTaskDate, newTaskDate); i++) {
      DateTime dateToDelay = getDateOnly(oldTaskDate, offsetDays: i);
      if (_delay[dateToDelay] == null) {
        _delay[dateToDelay] = [];
      }
      _delay[dateToDelay]!.add(task);
    }
    if (_active[newTaskDate] == null) {
      _active[newTaskDate] = [];
    }
    _active[newTaskDate]!.add(task);
    todayTasks = (_active[_selectedDay] ?? []) +
        (_complete[_selectedDay] ?? []) +
        (_delay[_selectedDay] ?? []);
    print("new lists for $_selectedDay");
    print("active: $_active");
    print("delay: $_delay");
    print("comp: $_complete");
    print("today: $todayTasks");
    setState(() {
      getTasksForDay(oldTaskDate);
      getTasksForDay(newTaskDate);
      getTaskList();
    });
  }

  void deleteTask(Task task) {
    DateTime deletionStart = task.timeStart.isBefore(widget.startOfMonth)
        ? widget.startOfMonth
        : task.timeStart;
    DateTime deletionEnd = task.timeCurrent;
    int daysToDelete = daysBetween(deletionStart, deletionEnd) + 1;

    for (int i = 0; i < daysToDelete; i++) {
      DateTime toDeleteTaskFrom = getDateOnly(deletionStart, offsetDays: i);
      _active[toDeleteTaskFrom]!.remove(task);
      _complete[toDeleteTaskFrom]!.remove(task);
      _delay[toDeleteTaskFrom]!.remove(task);
      setState(() {
        getTasksForDay(toDeleteTaskFrom);
      });
    }
    todayTasks = (_active[_selectedDay] ?? []) +
        (_complete[_selectedDay] ?? []) +
        (_delay[_selectedDay] ?? []);
    setState(() {
      getTaskList();
    });
  }

  /// Disposes of the resources used by the widget
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// return a list of active tasks in a day (for dots)
  List<Task> getTasksForDay(DateTime day) {
    var taskForDay = _active[getDateOnly(day)] ?? [];
    print("getting tasks for day $day: $taskForDay");
    return taskForDay;
  }

  /// Gets the list of tasks for the current day (for bottom)
  ListView getTaskList() {
    return ListView.builder(
      itemCount: todayTasks.length,
      itemBuilder: (context, index) {
        Task task = todayTasks[index];
        return TaskCard(task: task, dateOfCard: _selectedDay, state: this);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => WeeklyTaskView(),
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
                    final newTodayTasks =
                        await _db.fetchTodayTasks(selectedDay);
                    setState(() {
                      _selectedDay = getDateOnly(selectedDay);
                      _focusedDay = focusedDay;
                      todayTasks = newTodayTasks;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _selectedDay = getDateOnly(focusedDay);
                },
                eventLoader: (day) {
                  return getTasksForDay(day);
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, tasks) {
                    if (tasks.isNotEmpty) {
                      return Positioned(
                        left: 1,
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
                child: getTaskList(),
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
                            _active[newTaskDateStart] = [
                              ..._active[newTaskDateStart] ?? [],
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
