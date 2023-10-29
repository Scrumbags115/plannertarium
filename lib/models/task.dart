import 'package:planner/common/recurrence.dart';
import 'package:planner/common/date.dart';

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

  set Name(String newName) {
    timeModified = DateTime.now();
    name = newName;
  }
  String get Name => name;

  set Description(String newDescription) {
    timeModified = DateTime.now();
    description = newDescription;
  }
  String get Description => description;

  set TimeDue(newTimeDue) { // Can't force DateTime type because it can be null
    timeModified = DateTime.now();
    timeDue = newTimeDue;
  }
  get TimeDue => timeDue;

  set Location(String newLocation) {
    timeModified = DateTime.now();
    location = newLocation;
  }
  String get Location => location;

  set Color(String newColor) {
    timeModified = DateTime.now();
    location = newColor;
  }
  String get Color => color;

  set Tags(Set<String> newTags) {
    timeModified = DateTime.now();
    tags = newTags;
  }
  Set<String> get Tags => tags;

  set RecurrenceRules(newRecurrence) { // Can't force Recurrence type because it can be null
    timeModified = DateTime.now();
    recurrenceRules = newRecurrence;
  }
  get RecurrenceRules => recurrenceRules;

  get TimeCreated => timeCreated;

  get TimeModified => timeModified;

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
