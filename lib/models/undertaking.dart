import 'package:flutter/foundation.dart';
import 'package:planner/common/recurrence.dart';
import 'package:planner/common/time_management.dart';

class Undertaking {
  late String _name = "";
  late final String _id;
  late String _description = "";
  late String _location = "";
  late String _color = "#919191";
  late List<String> _tags = <String>[];
  late Recurrence _recurrenceRules;
  late DateTime _timeStart;
  late final DateTime _timeCreated;
  late DateTime timeModified;

  /// Default constructor with minimum required info
  /// Good for if you want to add a new undertaking from user with missing fields
  Undertaking(
      {String? name,
      String? id,
      String? description,
      String? location,
      String? color,
      List<String>? tags,
      Recurrence? recurrenceRules,
      DateTime? timeStart,
      DateTime? timeCreated,
      DateTime? timeModified}) {
    _name = name ?? "";
    _id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _description = description ?? "";
    _location = location ?? "";
    _color = color ?? "#919191";
    _tags = tags ?? <String>[];
    _recurrenceRules = recurrenceRules ?? Recurrence();
    _timeStart = timeStart ?? DateTime.now();
    _timeCreated = timeCreated ?? DateTime.now();
    this.timeModified = timeModified ?? _timeCreated;
  }

  /// Alternate constructor so VSCode autogenerates all fields
  /// Good for reading from database
  Undertaking.requireFields(
      {required String name,
      required String id,
      required String description,
      required String location,
      required String color,
      required List<String> tags,
      required Recurrence recurrenceRules,
      required DateTime timeStart,
      required DateTime timeCreated,
      required this.timeModified}) {
    _name = name;
    _id = id;
    _description = description;
    _location = location;
    _color = color;
    _tags = tags;
    _recurrenceRules = recurrenceRules;
    _timeStart = timeStart;
    _timeCreated = timeCreated;
  }

  /// Alternate constructor to get a task obj from some valid map
  /// Can have ID as a separate parameter if not in the map
  /// Good for reading from database
  Undertaking.fromMap(Map<String, dynamic> map, {String? id}) {
    try {
      _name = map['name'];
      _id = id ?? map['id'];
      _description = map['description'];
      _location = map['location'];
      _color = map['hex color'];
      _tags = [];
      map['tags'].forEach((tag) {
        _tags.add(tag.toString());
      });
      _recurrenceRules = Recurrence.fromMap(map['recurrence rules']);
      _timeStart = toDateIfTimestamp(map['time start']);
      _timeCreated = toDateIfTimestamp(map['time created']);
      timeModified = toDateIfTimestamp(map['time modified']);
    } catch (e) {
      throw Exception("Given map is malformed!\n$e");
    }
  }

  /// returns a mapping with kv pairs corresponding to Firebase's
  /// possibly a better getter
  Map<String, dynamic> toMap({keepClasses = false, includeID = false}) {
    Map<String, dynamic> map = {
      'name': _name,
      'description': _description,
      'location': _location,
      'hex color': _color,
      'recurrence rules':
          keepClasses ? _recurrenceRules : _recurrenceRules.toMap(),
      'tags': keepClasses ? _tags : _tags.toList(),
      'time start': _timeStart,
      'time created': _timeCreated,
      'time modified': timeModified
    };

    if (includeID) {
      map['id'] = _id;
    }

    return map;
  }

  set name(String newName) {
    timeModified = DateTime.now();
    _name = newName;
  }

  String get name => _name;

  String get id => _id;

  set description(String newDescription) {
    timeModified = DateTime.now();
    _description = newDescription;
  }

  String get description => _description;

  set location(String newLocation) {
    timeModified = DateTime.now();
    _location = newLocation;
  }

  String get location => _location;

  set color(String newColor) {
    timeModified = DateTime.now();
    _color = newColor;
  }

  String get color => _color;

  set tags(List<String> newTags) {
    timeModified = DateTime.now();
    _tags = newTags;
  }

  List<String> get tags => _tags;

  set recurrenceRules(Recurrence newRecurrence) {
    timeModified = DateTime.now();
    _recurrenceRules = newRecurrence;
  }

  Recurrence get recurrenceRules => _recurrenceRules;

  set timeStart(DateTime newTimeStart) {
    timeModified = DateTime.now();
    _timeStart = newTimeStart;
  }

  DateTime get timeStart => _timeStart;

  DateTime get timeCreated => _timeCreated;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // if (other is Task &&
    //     _name == other._name &&
    //     _id == other._id &&
    //     _description == other._description &&
    //     _location == other._location &&
    //     _color == other._color) {
    //       // print("Strings are all equal");
    //     } else {
    //       print("Strings are not equal");
    //     }

    // if (other is Task &&
    //     _timeStart == other._timeStart &&
    //     _timeCreated == other._timeCreated &&
    //     _timeModified == other._timeModified) {
    //       // print("Times are all equal");
    //     } else {
    //       print("Times are not equal");
    //     }

    // if (other is Task &&
    //     listEquals(_tags, other._tags)) {
    //       // print("Tags are equal");
    //     } else{
    //       print("Tags are not equal");
    //     }

    // if (other is Task &&
    //     _recurrenceRules == other._recurrenceRules) {
    //       // print("Recurrence rules are equal");
    //     } else {
    //       print("Recurrence rules are not equal");
    //     }

    return other is Undertaking &&
        _name == other._name &&
        _id == other._id &&
        _description == other._description &&
        _location == other._location &&
        _color == other._color &&
        listEquals(_tags, other._tags) &&
        _recurrenceRules == other._recurrenceRules &&
        _timeStart == other._timeStart &&
        _timeCreated == other._timeCreated;
  }

  @override
  int get hashCode {
    return Object.hash(
      _name,
      _id,
      _description,
      _location,
      _color,
      _tags.toString(),
      _recurrenceRules.toString(),
      _timeStart,
      _timeCreated,
    );
  }
}
