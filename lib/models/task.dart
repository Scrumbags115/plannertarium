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
  DateTime? timeCreated;
  DateTime? timeModified;

  /// Default constructor
  /// Good for if you want to add a new task from user
  Task(
      {required this.name,
      this.description = "",
      this.timeDue,
      this.location = "",
      this.color = "#919191",
      required this.tags,
      this.recurrenceRules,
      this.timeCreated}) {
    timeCreated = timeCreated ?? DateTime.now();
    timeModified = DateTime.now();
  }

  void setName(String newName) {
    timeModified = DateTime.now();
    name = newName;
  }

  void setDescription(String newDescription) {
    timeModified = DateTime.now();
    description = newDescription;
  }

  void setTimeDue(DateTime newTimeDue) {
    timeModified = DateTime.now();
    timeDue = newTimeDue;
  }

  /// Alternate constructor so VSCode autogenerates all fields
  /// Good for reading from database
  Task.requireFields(
      {required this.name,
      required this.description,
      required this.timeDue,
      required this.location,
      required this.color,
      required this.tags,
      required this.recurrenceRules,
      required this.timeCreated,
      required this.timeModified});

  /// returns a mapping with kv pairs corresponding to Firebase's
  /// possibly a better getter 
  Map<String, dynamic> toMap({keepClasses = false}) {
    return ({
      'date created': timeCreated,
      'date modified': timeModified,
      'description': description,
      'due date': timeDue,
      'hex color': color,
      'location': location,
      'recurrence rules':
          keepClasses ? recurrenceRules : recurrenceRules?.toMap(),
      'tags': keepClasses ? tags : tags.toList(),
      'task name': name
    });
  }
}
