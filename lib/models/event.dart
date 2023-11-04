import 'package:planner/common/recurrence.dart';

// import recurrence class here
class Event {
  String name;
  String description;
  DateTime timeCreated = DateTime.now();
  DateTime timeModified = DateTime.now();
  DateTime? timeStart;
  DateTime? timeEnd;
  String color;
  String location;
  Set<String> tags = <String>{};
  Recurrence? recurrenceRules;


  Event(
      {required this.name,
      this.description = "",
      this.location = "",
      this.color = "",
      required this.tags,
      this.recurrenceRules,
      required this.timeStart,
      required this.timeEnd});

  /// Alternate constructor so VSCode autogenerates all fields
  /// Good for reading from database
  Event.requireFields(
      {required this.name,
      required this.description,
      required this.timeCreated,
      required this.timeModified,
      required this.timeStart,
      required this.timeEnd,
      required this.color,
      required this.location,
      required this.tags,
      required this.recurrenceRules});

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

  set TimeStart(newTimeStart) {
    timeModified = DateTime.now();
    timeStart = newTimeStart;
  }

  get TimeStart => timeStart;

  set TimeEnd(newTimeEnd) {
    timeModified = DateTime.now();
    timeEnd = newTimeEnd;
  }

  get TimeEnd => timeEnd;

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
      timeCreated; // Do not want to timeCreated this after the constructor

  get TimeModified =>
      timeModified; // Do not want to change timeModified unless modifying a field

  Map<String, dynamic> toMap() {
    return ({
      'date created': timeCreated,
      'date modified': timeModified,
      'description': description,
      'event time start': timeStart,
      'event time end': timeEnd,
      'hex color': color,
      'location': location,
      'recurrence rules': recurrenceRules?.toMap(),
      'tags': tags.toList(),
      'event name': name
    });
  }
}

/// Turn a properly formatted map into an Event class
///
/// the map must have all the proper fields
Event mapToEvent(Map<String, dynamic> m) {
  // Kinda messy, but dealing with types are very annoying
  // ex: why does Set() make a _HashSet??
  try {
    final name = m["event name"];
    final description = m["description"];
    var timeCreated = m["date created"];
    var timeModified = m["date modified"];
    var timeStart = m["event time start"];
    var timeEnd = m["event time end"];
    if (timeCreated != null) {
      timeCreated = timeCreated.toDate();
    }
    if (timeModified != null) {
      timeModified = timeModified.toDate();
    }
    if (timeStart != null) {
      timeStart = timeStart.toDate();
    }
    if (timeEnd != null) {
      timeEnd = timeEnd.toDate();
    }
    final color = m["hex color"];
    final location = m["location"];
    var tagsList = m["tags"];
    var tags = <String>{};
    for (final tag in tagsList) {
      tags.add(tag);
    }
    final recurrenceRulesList = m["recurrence rules"];
    final recurrenceDates = recurrenceRulesList["repeat on days"];
    List<bool>? dates = <bool>[];
    if (recurrenceDates != null) {
      for (final date in recurrenceDates) {
        dates.add(date);
      }
    } else {
      dates = null;
    }
    final recurrenceRules = Recurrence.requireFields(
        enabled: recurrenceRulesList["enabled"],
        timeStart: recurrenceRulesList["starts on"],
        timeEnd: recurrenceRulesList["ends on"],
        dates: dates);
    return Event.requireFields(
        name: name,
        description: description,
        timeCreated: timeCreated,
        timeModified: timeModified,
        timeStart: timeStart,
        timeEnd: timeEnd,
        color: color,
        location: location,
        tags: tags,
        recurrenceRules: recurrenceRules);
  } catch (e) {
    throw Exception("Given map is malformed!\n$e");
  }
}
