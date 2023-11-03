import 'package:planner/common/recurrence.dart';

/// Class to hold information about a task
class Task {
  late String _name;
  late String _id;
  late String _description;
  late bool _completed;
  late String _location;
  late String _color;
  late Set<String> _tags = {};
  late Recurrence? _recurrenceRules;
  late DateTime _timeStart;
  DateTime? _timeDue;
  late DateTime _timeCurrent;
  late final DateTime _timeCreated;
  late DateTime _timeModified;

  /// Default constructor with minimum required info
  /// Good for if you want to add a new task from user with missing fields
  Task(
      {String name = "",
      String? id,
      String description = "",
      bool completed = false,
      String location = "",
      String color = "#919191",
      Set<String> tags = const <String>{}, // const will be eliminated?
      Recurrence? recurrenceRules,
      DateTime? timeStart,
      DateTime? timeDue,
      DateTime? timeCurrent,
      DateTime? timeCreated,
      DateTime? timeModified}) {
    _name = name;
    _id = id ?? DateTime.now().millisecondsSinceEpoch as String;
    _description = description;
    _completed = completed;
    _location = location;
    _color = color;
    // tags = tags.isEmpty ? Set() : Set.from(tags);
    _tags = tags;
    _recurrenceRules = recurrenceRules;
    _timeStart = timeStart ?? DateTime.now();
    _timeDue = timeDue;
    _timeCurrent = timeCurrent ?? _timeStart;
    _timeCreated = timeCreated ?? DateTime.now();
    _timeModified = timeModified ?? _timeCreated;
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
      required Set<String> tags,
      required Recurrence recurrenceRules,
      required DateTime timeStart,
      required DateTime timeDue,
      required DateTime timeCurrent,
      required DateTime timeCreated,
      required DateTime timeModified}) {
    _name = name;
    _id = id;
    _description = description;
    _completed = completed;
    _location = location;
    _color = color;
    _tags = tags;
    _recurrenceRules = recurrenceRules;
    _timeStart = timeStart;
    _timeDue = timeDue;
    _timeCurrent = timeCurrent;
    _timeCreated = timeCreated;
    _timeModified = timeModified;
  }

  /// Alternate constructor to get a task obj from some valid map
  /// Good for reading from database
  Task.mapToTask(Map<String, dynamic> map) {
    _name = map['task name'];
    _description = map['description'];
    _completed = map['completed'];
    _location = map['location'];
    _color = map['hex color'];
    _tags = map['tags'];
    _recurrenceRules = map['recurrence rules'];
    _timeStart = map['start date'];
    _timeDue = map['due date'];
    _timeCurrent = map['current date'];
    _timeCreated = map['date created'];
    _timeModified = map['date modified'];
  }

  set name(String newName) {
    _timeModified = DateTime.now();
    _name = newName;
  }

  String get name => _name;

  set description(String newDescription) {
    _timeModified = DateTime.now();
    _description = newDescription;
  }

  String get description => _description;

  set completed(bool newCompleted) {
    _timeModified = DateTime.now();
    _completed = newCompleted;
  }

  bool get completed => _completed;

  set location(String newLocation) {
    _timeModified = DateTime.now();
    _location = newLocation;
  }

  String get location => _location;

  set color(String newColor) {
    _timeModified = DateTime.now();
    _color = newColor;
  }

  String get color => _color;

  set tags(Set<String> newTags) {
    _timeModified = DateTime.now();
    _tags = newTags;
  }

  Set<String> get tags => _tags;

  set recurrenceRules(newRecurrence) {
    // Can't force Recurrence type because it can be null
    _timeModified = DateTime.now();
    _recurrenceRules = newRecurrence;
  }

  get recurrenceRules => _recurrenceRules;

  set timeCurrent(newTimeCurrent) {
    // Can't force DateTime type because it can be null
    _timeModified = DateTime.now();
    _timeCurrent = newTimeCurrent;
  }

  get timeCurrent => _timeCurrent;

  set timeStart(newTimeStart) {
    // Can't force DateTime type because it can be null
    _timeModified = DateTime.now();
    _timeStart = newTimeStart;
  }

  get timeStart => _timeStart;

  set timeDue(newTimeDue) {
    // Can't force DateTime type because it can be null
    _timeModified = DateTime.now();
    _timeDue = newTimeDue;
  }

  get timeDue => _timeDue;

  get timeCreated =>
      _timeCreated; // Do not want to change timeCreated this after the constructor

  get timeModified =>
      _timeModified; // Do not want to change timeModified unless modifying a field

  /// returns a mapping with kv pairs corresponding to Firebase's
  /// possibly a better getter
  Map<String, dynamic> toMap({keepClasses = false}) {
    return ({
      'task name': _name,
      'description': _description,
      'completed': _completed,
      'location': _location,
      'hex color': _color,
      'recurrence rules':
          keepClasses ? _recurrenceRules : _recurrenceRules?.toMap(),
      'tags': keepClasses ? _tags : _tags.toList(),
      'start date': _timeStart,
      'due date': _timeDue,
      'current date': _timeCurrent,
      'date created': _timeCreated,
      'date modified': _timeModified
    });
  }
}
