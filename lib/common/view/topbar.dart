import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/dailyEventView.dart';
import 'package:planner/view/monthlyEvenView.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:planner/view/dailyTaskView.dart';
import 'package:planner/view/weeklyEventView.dart';
import 'package:planner/view/weeklyTaskView.dart';

RoundedRectangleBorder roundedRectangleBackground =
    const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
  bottomLeft: Radius.circular(20),
  bottomRight: Radius.circular(20),
));

/// A void function that shows a dialog with a search bar to search for tasks.
void showSearchBar(BuildContext context) {
  TextEditingController searchController = TextEditingController();
  DatabaseService db = DatabaseService();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Search'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Search'),
            onPressed: () async {
              String searchQuery = searchController.text;
              List<Task> searchTask = await db.searchAllTask(searchQuery);
              List<Event> searchEvent = await db.searchAllEvent(searchQuery);
              showTaskDetailsDialog(
                  searchQuery, searchTask, searchEvent, context);
            },
          ),
        ],
      );
    },
  );
}

/// A void function that searches in a query and a list of tasks to query from
/// Returns a list of tasks with informations of each tasks
void showTaskDetailsDialog(
    String searchQuery, List<Task> tasks, List<Event> events, context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Results for "$searchQuery"'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tasks.map((task) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${task.completed ? "✅" : "❌"} ${task.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('  ${task.description}'),
                      Text(
                          '  Currently on: ${getDateAsString(task.timeCurrent)}'),
                      Text(
                          '  Date created: ${getDateAsString(task.timeCreated)}'),
                      const Divider(),
                    ],
                  );
                }).toList() +
                events.map((event) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🕒 ${event.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('  ${event.description}'),
                      Text('  Starts at: ${getTimeAsString(event.timeStart)}'),
                      Text(
                          '  Date created: ${getDateAsString(event.timeCreated)}'),
                      const Divider(),
                    ],
                  );
                }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

AppBar _getTopBarDaily(bool forEvents, BuildContext context, state) {
  return AppBar(
    elevation: 1,
    backgroundColor: Colors.white,
    shape: roundedRectangleBackground,
    leading: IconButton(
      icon: const Icon(Icons.calendar_month_rounded, color: Colors.black),
      onPressed: () {
        state.selectDate(context: context);
      },
    ),
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
                activeColor: Colors.white,
                activeTrackColor: Colors.cyan,
                inactiveThumbColor: Colors.blueGrey.shade600,
                inactiveTrackColor: Colors.grey.shade400,
                splashRadius: 50.0,
                value: forEvents,
                onChanged: (value) {
                  state.setState(() {
                    forEvents = value;
                  });
                  if (forEvents) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DayView(date: state.today),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskView(),
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
          showSearchBar(context);
        },
      ),
    ],
  );
}

AppBar _getTopBarWeekly(bool forEvents, BuildContext context, state) {
  return AppBar(
    shape: roundedRectangleBackground,
    elevation: 1,
    backgroundColor: Colors.white,
    leading: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              state.loadPreviousWeek();
            },
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.black),
            onPressed: () async {
              DateTime initialDate;
              // todo: This is done to avoid extreme duplication of code, but the way the event and task view are written are fundamentally very different to trying to call it with the same signature will crash. This just ensures that if the view's object is different, the proper signature is called
              try {
                initialDate = state.today;
              } on NoSuchMethodError catch (_) {
                initialDate = state.widget.monday;
              }
              final DateTime? selectedDate = await datePicker(state.context,
                  initialDate: initialDate, defaultDate: null);
              await state.resetView(selectedDate);
            },
          ),
        ),
      ],
    ),
    title: Center(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 20),
                const Text(
                  'Tasks ',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                Switch(
                  activeColor: Colors.white,
                  activeTrackColor: Colors.cyan,
                  inactiveThumbColor: Colors.blueGrey.shade600,
                  inactiveTrackColor: Colors.grey.shade400,
                  splashRadius: 50.0,
                  value: forEvents,
                  onChanged: (value) {
                    state.setState(() {
                      forEvents = value;
                    });
                    if (forEvents) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WeekView(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WeeklyTaskView(),
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
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.search, color: Colors.black),
        onPressed: () {
          showSearchBar(context);
        },
      ),
      IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.black),
        onPressed: () {
          state.loadNextWeek();
        },
      ),
    ],
  );
}

_getTopBarMonthly(bool forEvents, BuildContext context, state) {
  return AppBar(
    elevation: 1,
    backgroundColor: Colors.white,
    shape: roundedRectangleBackground,
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
                activeColor: Colors.white,
                activeTrackColor: Colors.cyan,
                inactiveThumbColor: Colors.blueGrey.shade600,
                inactiveTrackColor: Colors.grey.shade400,
                splashRadius: 50.0,
                value: forEvents,
                onChanged: (value) {
                  state.setState(() {
                    forEvents = value;
                  });
                  if (forEvents) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MonthView(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MonthlyTaskView(dayOfMonth: DateTime.now()),
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
          showSearchBar(context);
        },
      ),
    ],
  );
}

AppBar getTopBar(Type t, String window, BuildContext context, state) {
  bool forEvents = t == Event;
  switch (window) {
    case ("daily"):
      return _getTopBarDaily(forEvents, context, state);
    case ("weekly"):
      return _getTopBarWeekly(forEvents, context, state);
    default:
      return _getTopBarMonthly(forEvents, context, state);
  }
}
