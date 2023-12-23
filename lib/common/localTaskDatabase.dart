import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/models/task.dart';

void _addOrExtendMap(Map<DateTime, List<Task>> map, Task task, DateTime key) {
  if (map.containsKey(key)) {
    map[key]!.add(task);
  } else {
    map[key] = [];
    map[key]!.add(task);
  }
}

class LocalTaskDatabase {
  late Map<DateTime, List<Task>> active;
  late Map<DateTime, List<Task>> delayed;
  late Map<DateTime, List<Task>> completed;
  late DateTime windowStart; // inclusive
  late DateTime windowEnd; // non-inclusive

  LocalTaskDatabase() {
    active = {};
    delayed = {};
    completed = {};
  }

  void setFromTuple(
      (
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>
      ) tupleTaskMaps) {
    active = tupleTaskMaps.$1;
    completed = tupleTaskMaps.$2;
    delayed = tupleTaskMaps.$3;
  }

  /// Add a new (just created from (+) button) task to db
  void addNewTask(Task? taskMaybeNull) {
    if (taskMaybeNull == null) {
      return;
    }
    Task task = taskMaybeNull;
    _addOrExtendMap(active, task, task.timeCurrent);
  }

  void moveDelayedTask(Task task, DateTime oldTaskDate) {
    oldTaskDate = getDateOnly(oldTaskDate);
    DateTime newTaskDate = task.timeCurrent;

    active[oldTaskDate]!.remove(task);
    for (int i = 0; i < daysBetween(oldTaskDate, newTaskDate); i++) {
      DateTime dateToDelay = getDateOnly(oldTaskDate, offsetDays: i);
      delayed[dateToDelay]?.add(task);
    }
    active[newTaskDate]?.add(task);
  }

  void deleteTask(Task task, DateTime deletionStart) {
    DateTime deletionEnd = task.timeCurrent;
    int daysToDelete = daysBetween(deletionStart, deletionEnd) + 1;

    for (int i = 0; i < daysToDelete; i++) {
      DateTime toDeleteTaskFrom = getDateOnly(deletionStart, offsetDays: i);
      active[toDeleteTaskFrom]?.remove(task);
      completed[toDeleteTaskFrom]?.remove(task);
      delayed[toDeleteTaskFrom]?.remove(task);
    }
  }

  List<Task> getTasksForDate(DateTime date) {
    return (active[date] ?? []) +
        (completed[date] ?? []) +
        (delayed[date] ?? []);
  }

  void toggleCompleted(Task task, DateTime togglingStart) {
    togglingStart = getDateOnly(togglingStart);
    DateTime newTaskDate = task.timeCurrent;

    for (int i = 0; i < daysBetween(togglingStart, newTaskDate) + 1; i++) {
      // get the date of the current day
      DateTime curr = getDateOnly(togglingStart, offsetDays: i);

      // if the task was just completed
      if (task.completed) {
        // and if the task was active
        if (active[curr]!.contains(task)) {
          // then remove it from active and add it to complete
          active[curr]!.remove(task);
          completed[curr]!.add(task);
        }

        // or if the task was delayed
        if (delayed[curr]!.contains(task)) {
          // then remove it from delayed and add it to complete
          delayed[curr]!.remove(task);
          completed[curr]!.add(task);
        }
        // if the task was just uncompleted
      } else {
        // and if the task was complete
        if (completed[curr]!.contains(task)) {
          // then remove it from complete and add it to active
          completed[curr]!.remove(task);
          // if the task ws delayed
          if (curr.isBefore(task.timeCurrent)) {
            // then add it to the delayed list
            delayed[curr]!.add(task);
          }

          if (curr.isAtSameMomentAs(task.timeCurrent)) {
            // otherwise add it to the active list
            active[curr]!.add(task);
          }
        }
      }
    }
  }
}
