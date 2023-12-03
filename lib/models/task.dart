import 'package:planner/common/time_management.dart';
import 'package:planner/models/undertaking.dart';

/// Class to hold information about a task
class Task extends Undertaking {
  late bool _completed = false;
  DateTime? _timeDue;
  late DateTime _timeCurrent;

  /// Default constructor with minimum required info
  /// Good for if you want to add a new task from user with missing fields
  Task(
      {super.name,
      super.id,
      super.description,
      bool completed = false,
      super.location,
      super.color,
      super.tags,
      super.recurrenceRules,
      super.timeStart,
      DateTime? timeDue,
      DateTime? timeCurrent,
      super.timeCreated,
      super.timeModified}) {
    _completed = completed;
    _timeDue = timeDue;
    _timeCurrent = timeCurrent ?? timeStart;
  }

  /// Alternate constructor so VSCode autogenerates all fields
  /// Good for reading from database
  Task.requireFields(
      {required super.name,
      required super.id,
      required super.description,
      required bool completed,
      required super.location,
      required super.color,
      required super.tags,
      required super.recurrenceRules,
      required super.timeStart,
      required DateTime timeDue,
      required DateTime timeCurrent,
      required super.timeCreated,
      required super.timeModified})
      : super.requireFields() {
    _completed = completed;
    _timeDue = timeDue;
    _timeCurrent = timeCurrent;
  }

  /// Alternate constructor to get a task obj from some valid map
  /// Can have ID as a separate parameter if not in the map
  /// Good for reading from database
  Task.fromMap(Map<String, dynamic> map, {String? id})
      : super.fromMap(map, id: id) {
    _completed = map['completed'];
    try {
      _timeDue = toDateIfTimestamp(map['time due']);
    } catch (e) {
      _timeDue = null;
    }
    _timeCurrent = toDateIfTimestamp(map['current date']);
  }

  /// returns a mapping with kv pairs corresponding to Firebase's
  /// possibly a better getter
  @override
  Map<String, dynamic> toMap({keepClasses = false, includeID = false}) {
    Map<String, dynamic> map = super.toMap();
    map['completed'] = _completed;
    map['time due'] = _timeDue;
    map['current date'] = _timeCurrent;
    return map;
  }

  void moveToNextDay() {
    timeCurrent = getDateOnly(timeCurrent, offsetDays: 1);
  }

  set completed(bool newCompleted) {
    timeModified = DateTime.now();
    _completed = newCompleted;
  }

  bool get completed => _completed;

  set timeCurrent(DateTime newTimeCurrent) {
    timeModified = DateTime.now();
    _timeCurrent = newTimeCurrent;
  }

  DateTime get timeCurrent => _timeCurrent;

  set timeDue(DateTime? newTimeDue) {
    timeModified = DateTime.now();
    _timeDue = newTimeDue;
  }

  DateTime? get timeDue => _timeDue;

  bool isDelayedOn(DateTime day) {
    return (day.isAtSameMomentAs(timeStart) || day.isAfter(timeStart)) && day.isBefore(timeCurrent);
  }

  @override
  String toString() {
    return "Task($name, $id)";
  }

  String toDetailedString() {
    return "Task($name, $id, $description, $completed, $location, $color, $recurrenceRules, $tags, $timeStart, $timeDue, $timeCurrent, $timeCreated, $timeModified)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Task) return false;

    bool taskVariablesEqual = completed == other._completed &&
        timeDue == other.timeDue &&
        timeCurrent == other.timeCurrent;
    if (!taskVariablesEqual) {
      // print("task variables are not equal")
      return false;
    }

    return super == other;
  }

  @override
  int get hashCode {
    return Object.hash(
      completed,
      timeDue,
      timeCurrent,
      super.hashCode,
    );
  }
}
