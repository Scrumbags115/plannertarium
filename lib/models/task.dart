import 'package:planner_app/common/recurrence.dart';

/// Class to hold information about a task
class Task {
  String name;
  String description;
  num timeDue;
  String location;
  String color;
  Set<String> tags;
  Recurrence? recurrenceRules;
  final num timeCreated = DateTime.now().millisecondsSinceEpoch / 1000;
  num timeModified = 0;

  Task(
      {required this.name,
      this.description = "",
      this.timeDue = 0,
      this.location = "",
      this.color = "#919191",
      required this.tags,
      this.recurrenceRules}) {
    timeModified = timeCreated;
  }

  /// Alternate constructor so VSCode autogenerates all fields
  Task.require(
      {required this.name,
      required this.description,
      required this.timeDue,
      required this.location,
      required this.color,
      required this.tags,
      required this.recurrenceRules}) {
    timeModified = timeCreated;
  }

  /// returns a mapping with kv pairs corresponding to Firebase's
  toMap() {
    return ({
      'date created': timeCreated,
      'date modified': timeModified,
      'description': description,
      'due date': timeDue,
      'hex color': color,
      'location': location,
      'recurrence rules':
          recurrenceRules?.toMap() ?? Recurrence(false, 0, 0, []).toMap(),
      'tags': tags.toList(),
      'task name': name
    });
  }
}
