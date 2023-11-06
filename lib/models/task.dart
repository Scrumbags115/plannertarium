import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:planner/common/recurrence.dart';

/// Class to hold information about a task
class Task {
  late String _name = "";
  late final String _id;
  late String _description = "";
  late bool _completed = false;
  late String _location = "";
  late String _color = "#919191";
  late List<String> _tags = <String>[];
  late Recurrence _recurrenceRules;
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
      List<String> tags = const <String>[], // const will be eliminated?
      Recurrence? recurrenceRules,
      DateTime? timeStart,
      DateTime? timeDue,
      DateTime? timeCurrent,
      DateTime? timeCreated,
      DateTime? timeModified}) {
    _name = name;
    _id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _description = description;
    _completed = completed;
    _location = location;
    _color = color;
    _tags = tags;
    _recurrenceRules = recurrenceRules ?? Recurrence();
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
      required List<String> tags,
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
  /// Can have ID as a separate parameter if not in the map
  /// Good for reading from database
  Task.fromMap(Map<String, dynamic> map, {String? id}) {
    _name = map['task name'];
    _id = id ?? map['id'];
    _description = map['description'];
    _completed = map['completed'];
    _location = map['location'];
    _color = map['hex color'];
    _tags = [];
    map['tags'].forEach((tag) {_tags.add(tag.toString());});
    _recurrenceRules = Recurrence.fromMap(map['recurrence rules']);
    _timeStart = map['start date'] is Timestamp ? (map['start date'] as Timestamp).toDate() : map['start date'];
    _timeDue = map['due date'] is Timestamp ? (map['due date'] as Timestamp).toDate() : map['due date'];
    _timeCurrent = map['current date'] is Timestamp ? (map['current date'] as Timestamp).toDate() : map['current date'];
    _timeCreated = map['date created'] is Timestamp ? (map['date created'] as Timestamp).toDate() : map['date created'];
    _timeModified = map['date modified'] is Timestamp ? (map['date modified'] as Timestamp).toDate() : map['date modified'];
  }

  /// returns a mapping with kv pairs corresponding to Firebase's
  /// possibly a better getter
  Map<String, dynamic> toMap({keepClasses = false, includeID = false}) {
    Map<String, dynamic> map = {'task name': _name,
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
                              };
    if (includeID)
      map['id'] = _id;
    return map;
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

  String get id => _id;

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

  set tags(List<String> newTags) {
    _timeModified = DateTime.now();
    _tags = newTags;
  }

  List<String> get tags => _tags;

  set recurrenceRules(Recurrence newRecurrence) {
    // Can't force Recurrence type because it can be null
    _timeModified = DateTime.now();
    _recurrenceRules = newRecurrence;
  }

  Recurrence get recurrenceRules => _recurrenceRules;

  set timeCurrent(DateTime newTimeCurrent) {
    _timeModified = DateTime.now();
    _timeCurrent = newTimeCurrent;
  }

  DateTime get timeCurrent => _timeCurrent;

  set timeStart(DateTime newTimeStart) {
    _timeModified = DateTime.now();
    _timeStart = newTimeStart;
  }

  DateTime get timeStart => _timeStart;

  set timeDue(DateTime? newTimeDue) {
    _timeModified = DateTime.now();
    _timeDue = newTimeDue;
  }

  DateTime? get timeDue => _timeDue;

  DateTime get timeCreated => _timeCreated; // Do not want to change timeCreated this after the constructor

  DateTime get timeModified => _timeModified; // Do not want to change timeModified unless modifying a field

  @override
  String toString() {
    return "Task($name, $id, $recurrenceRules)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        _name == other._name &&
        _id == other._id &&
        _description == other._description &&
        _completed == other._completed &&
        _location == other._location &&
        _color == other._color &&
        listEquals(_tags, other._tags) &&
        _recurrenceRules == other._recurrenceRules &&
        _timeStart == other._timeStart &&
        _timeDue == other._timeDue &&
        _timeCurrent == other._timeCurrent &&
        _timeCreated == other._timeCreated &&
        _timeModified == other._timeModified;
  }

  @override
  int get hashCode {
    return Object.hash(
      _name,
      _id,
      _description,
      _completed,
      _location,
      _color,
      _tags,
      _recurrenceRules,
      _timeStart,
      _timeDue,
      _timeCurrent,
      _timeCreated,
      _timeModified,
    );
  }
}