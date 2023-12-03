import 'package:flutter/material.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/dayView.dart';
import 'package:planner/view/monthView.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:planner/view/taskView.dart';
import 'package:planner/view/weekView.dart';
import 'package:planner/view/weeklyTaskView.dart';

RoundedRectangleBorder roundedRectangleBackground =
    const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
  bottomLeft: Radius.circular(20),
  bottomRight: Radius.circular(20),
));

AppBar _getTopBarDaily(bool forEvents, BuildContext context, state) {
  return AppBar(
    elevation: 1,
    backgroundColor: Colors.white,
    shape: roundedRectangleBackground,
    leading: IconButton(
      icon: const Icon(Icons.calendar_month_rounded, color: Colors.black),
      onPressed: () {
        state.selectDate();
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
                        builder: (context) => const TaskView(),
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
          state.showSearchBar(context);
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
            onPressed: () {
              state.datePicker();
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
                          builder: (context) => const WeekView(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WeeklyTaskView(),
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
                        builder: (context) => const MonthlyTaskView(),
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
