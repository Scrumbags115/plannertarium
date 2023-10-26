import 'package:planner/common/recurrence.dart';

/// Class to hold information about a task
class Task {
  String name;
  String description;
  DateTime? timeDue;
  String location;
  String color;
  Set<String> tags;
  Recurrence? recurrenceRules;
  final DateTime? timeCreated = DateTime.now();
  DateTime? timeModified;

  Task(
      {required this.name,
      this.description = "",
      this.timeDue,
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
      'recurrence rules': recurrenceRules?.toMap(),
      'tags': tags.toList(),
      'task name': name
    });
  }
}
