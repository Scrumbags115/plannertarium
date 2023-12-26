import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/localTaskDatabase.dart';
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

  /// Performs asynchronous initialization for the widget
  void asyncInitState() async {
    await setData();
    setState(() {});
  }

  /// Asynchronously fetches tasks for the current week
  Future<void> setData() async {
    DateTime firstOfMonth = getMonthAsDateTime(today);
    localDB.setFromTuple(await _db.getTaskMapsMonth(firstOfMonth));
  }

  void toggleCompleted(Task task) {
    DateTime startOfMonth = getMonthAsDateTime(today);
    localDB.toggleCompleted(task, startOfMonth);
    updateCalendarDots();
    setState(() {
      getTaskList();
    });
  }

  void moveDelayedTask(Task task, DateTime oldTaskDate) async {
    localDB.moveDelayedTask(task, oldTaskDate);
    updateCalendarDots();
    setState(() {
      getTaskList();
    });
  }

  void deleteTask(Task task) {
    DateTime startOfMonth = getMonthAsDateTime(today);
    DateTime deletionStart =
        task.timeStart.isBefore(startOfMonth) ? startOfMonth : task.timeStart;
    localDB.deleteTask(task, deletionStart);
    updateCalendarDots();
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
    return localDB.active[getDateOnly(day)] ?? [];
  }

  void updateCalendarDots() {
    DateTime startOfMonth = getMonthAsDateTime(today);
    DateTime startOfNextMonth = getNextMonthAsDateTime(today);

    for (int i = 0; i < daysBetween(startOfMonth, startOfNextMonth); i++) {
      DateTime curr = getDateOnly(startOfMonth, offsetDays: i);
      setState(() {
        getTasksForDay(curr);
      });
    }
  }

  /// Gets the list of tasks for the current day (for bottom)
  ListView getTaskList() {
    return ListView.builder(
      itemCount: localDB.getTasksForDate(today).length,
      itemBuilder: (context, index) {
        Task task = localDB.getTasksForDate(today)[index];
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
                        localDB.addNewTask(newTask);
                        setState(() {
                          getTaskList();
                        });
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
