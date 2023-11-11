import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/recurrence.dart';
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
      {String name = "",
      String? id,
      String description = "",
      bool completed = false,
      String location = "",
      String color = "#919191",
      List<String> tags = const <String>[],
      Recurrence? recurrenceRules,
      DateTime? timeStart,
      DateTime? timeDue,
      DateTime? timeCurrent,
      DateTime? timeCreated,
      DateTime? timeModified})
      : super() {
    _completed = completed;
    _timeDue = timeDue;
    _timeCurrent = timeCurrent ?? this.timeStart;
  }

  /// Alternate constructor so VSCode autogenerates all fields
  /// Good for reading from database
  Task.requireFields(
      {required String name,
      required String id,
      required String description,
      required bool completed,
      required String location,
      required String color,
      required List<String> tags,
      required Recurrence recurrenceRules,
      required DateTime timeStart,
      required DateTime timeDue,
      required DateTime timeCurrent,
      required DateTime timeCreated,
      required DateTime timeModified})
      : super.requireFields(
            name: name,
            id: id,
            description: description,
            location: location,
            color: color,
            tags: tags,
            recurrenceRules: recurrenceRules,
            timeStart: timeStart,
            timeCreated: timeCreated,
            timeModified: timeModified) {
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
    _timeDue = toDateIfTimestamp(map['time due']);
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
    timeCurrent =
        DateTime(timeCurrent.year, timeCurrent.month, timeCurrent.day + 1);
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

  @override
  String toString() {
    return "Task($name, $id, $recurrenceRules)";
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
