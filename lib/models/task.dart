import 'package:planner/common/recurrence.dart';

/// Class to hold information about a task
class Task {
  String name;
  String description;
  bool completed;
  DateTime? timeCurrent;
  DateTime? timeStart;
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
      this.completed = false,
      this.timeStart,
      this.timeDue,
      this.location = "",
      this.color = "#919191",
      required this.tags,
      this.recurrenceRules,
      this.timeCreated}) {
    timeCreated = timeCreated ?? DateTime.now();
    timeModified = DateTime.now();
    timeCurrent = timeStart;
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

  set Completed(bool newCompleted) {
    timeModified = DateTime.now();
    completed = newCompleted;
  }

  bool get Completed => completed;

  set TimeCurrent(newTimeCurrent) {
    // Can't force DateTime type because it can be null
    timeModified = DateTime.now();
    timeCurrent = newTimeCurrent;
  }

  get TimeCurrent => timeCurrent;

  set TimeStart(newTimeStart) {
    // Can't force DateTime type because it can be null
    timeModified = DateTime.now();
    timeStart = newTimeStart;
  }

  get TimeStart => timeStart;

  set TimeDue(newTimeDue) {
    // Can't force DateTime type because it can be null
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

  set RecurrenceRules(newRecurrence) {
    // Can't force Recurrence type because it can be null
    timeModified = DateTime.now();
    recurrenceRules = newRecurrence;
  }

  get RecurrenceRules => recurrenceRules;

  get TimeCreated =>
      timeCreated; // Do not want to change timeCreated this after the constructor

  get TimeModified =>
      timeModified; // Do not want to change timeModified unless modifying a field

  /// Alternate constructor so VSCode autogenerates all fields
  /// Good for reading from database
  Task.requireFields(
      {required this.name,
      required this.description,
      required this.completed,
      required this.timeCurrent,
      required this.timeStart,
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
      'completed' : completed,
      'current date' : timeCurrent,
      'description': description,
      'start date' : timeStart,
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
