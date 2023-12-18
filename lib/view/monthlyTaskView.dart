import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/view/taskCard.dart';

class MonthlyTaskView extends StatefulWidget {
  late DateTime selectedDay;
  MonthlyTaskView({super.key, required DateTime dayOfMonth}) {
    selectedDay = getDateOnly(dayOfMonth);
  }
  @override
  MonthlyTaskViewState createState() => MonthlyTaskViewState();
}

class MonthlyTaskViewState extends State<MonthlyTaskView> {
  final DatabaseService _db = DatabaseService();
  late DateTime today;
  Map<DateTime, List<Task>> _active = {};
  Map<DateTime, List<Task>> _delay = {};
  Map<DateTime, List<Task>> _complete = {};

  /// Initializes the state of the widget
  @override
  void initState() {
    today = widget.selectedDay;
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget
  void asyncInitState() async {
    await setData();
    setState(() {});
  }

  /// Asynchronously fetches tasks for the current week
  Future<void> setData() async {
    var taskMaps = await _db.getTaskMapsMonth(getMonthAsDateTime(today));
    setState(() {
      _active = taskMaps.$1;
      _complete = taskMaps.$2;
      _delay = taskMaps.$3;
    });
  }

  void toggleCompleted(Task task) {
    DateTime startOfMonth = getMonthAsDateTime(today);
    DateTime startOfNextMonth = getNextMonthAsDateTime(today);
    for (int i = 0; i < daysBetween(startOfMonth, startOfNextMonth); i++) {
      DateTime curr = getDateOnly(startOfMonth, offsetDays: i);
      if (task.completed) {
        if (_active[curr]!.contains(task)) {
          // then remove it from active and add it to complete
          _active[curr]!.remove(task);
          _complete[curr]!.add(task);
        }

        // or if the task was delayed
        if (_delay[curr]!.contains(task)) {
          // then remove it from delayed and add it to complete
          _delay[curr]!.remove(task);
          _complete[curr]!.add(task);
        }
        //break;
      } else {
        if (_complete[curr]!.contains(task)) {
          // then remove it from complete and add it to active
          _complete[curr]!.remove(task);
          // if the task ws delayed
          if (curr.isBefore(task.timeCurrent)) {
            // then add it to the delayed list
            _delay[curr]!.add(task);
          }

          if (curr.isAtSameMomentAs(task.timeCurrent)) {
            // otherwise add it to the active list
            _active[curr]!.add(task);
          }
        }
      }
      setState(() {
        getTasksForDay(curr);
      });
    }

    setState(() {
      getTaskList();
    });
  }

  void moveDelayedTask(Task task, DateTime oldTaskDate) async {
    DateTime newTaskDate = task.timeCurrent;
    _active[oldTaskDate]!.remove(task);
    setState(() {});
    for (int i = 0; i < daysBetween(oldTaskDate, newTaskDate); i++) {
      DateTime dateToDelay = getDateOnly(oldTaskDate, offsetDays: i);
      if (_delay[dateToDelay] == null) {
        _delay[dateToDelay] = [];
      }
      _delay[dateToDelay]!.add(task);
      setState(() {
        getTasksForDay(dateToDelay);
      });
    }
    if (_active[newTaskDate] == null) {
      _active[newTaskDate] = [];
    }
    _active[newTaskDate]!.add(task);

    setState(() {
      getTaskList();
    });
  }

  void deleteTask(Task task) {
    DateTime startOfMonth = getMonthAsDateTime(today);
    DateTime deletionStart =
        task.timeStart.isBefore(startOfMonth) ? startOfMonth : task.timeStart;
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
    setState(() {
      getTaskList();
    });
  }

  /// Disposes of the resources used by the widget
  @override
  void dispose() {
    super.dispose();
  }

  /// return a list of active tasks in a day (for dots)
  List<Task> getTasksForDay(DateTime day) {
    var taskForDay = _active[getDateOnly(day)] ?? [];
    return taskForDay;
  }

  /// Gets the list of tasks for the current day (for bottom)
  ListView getTaskList() {
    return ListView.builder(
      itemCount: ((_active[today] ?? []) +
              (_complete[today] ?? []) +
              (_delay[today] ?? []))
          .length,
      itemBuilder: (context, index) {
        Task task = ((_active[today] ?? []) +
            (_complete[today] ?? []) +
            (_delay[today] ?? []))[index];
        return TaskCard(task: task, dateOfCard: today, state: this);
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
                firstDay: DateTime(2020, 10, 16),
                lastDay: DateTime(2130, 3, 14),
                focusedDay: getDateOnly(DateTime.now()),
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) {
                  return isSameDay(today, day);
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  if (!isSameDay(today, selectedDay)) {
                    final newTodayTasks =
                        await _db.fetchTodayTasks(selectedDay);
                    setState(() {
                      today = getDateOnly(selectedDay);
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  today = getDateOnly(focusedDay);
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
                            getTaskList();
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
