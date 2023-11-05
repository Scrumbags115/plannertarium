import 'package:cloud_firestore/cloud_firestore.dart';
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
  Event.clone(Event e): this.requireFields(name: e.name, description: e.description, timeCreated: e.timeCreated, timeModified: e.timeModified, timeStart: e.timeStart, timeEnd: e.timeEnd, color: e.color, location: e.location, tags: e.tags, recurrenceRules: e.recurrenceRules);

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

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Some checks to make sure the event object is valid with recurrence and crash with a more useful error message if caught
  /// used internally to run some basic checks before I assume things aren't null/are valid classes
  bool _validEventWithRecurrence() {

    // event fields must be valid, crash since something has probably gone very wrong
    if (timeStart == null || timeEnd == null) {
      throw Exception("Event is malformed? No timeStart/timeEnd value is set!");
    }

    // recurrence must have its fields be populated
    if (recurrenceRules!.timeStart == null || recurrenceRules!.timeEnd == null || recurrenceRules!.dates == null) {
      return false;
    }
    if (recurrenceRules?.timeStart == null || recurrenceRules?.timeEnd == null) {
      throw Exception("Event recurrence rules are enabled and not null, but the rest of the recurrence rules fields are unset!"); // I think this should be enforced
    }
    return true;
  }

  /// generate recurring events as specified by the recurrence rules in the Event object
  ///
  /// to exclude generated the current event, set excludeMyself to true
  /// If the event day is not included recurring days then the event day will be ignored
  /// ex wednesday for event but recurrence is every thursday
  List<Event> generateRecurringEvents({excludeMyself = false}) {
    List<Event> eventList = [];
    // if recurrence rules are nonexistent or disabled, there are no new events to return
    if (recurrenceRules == null || recurrenceRules?.enabled == null) {
      return eventList;
    }
    // if recurrence is not enabled, there are no events to return
    if (recurrenceRules!.enabled == false) {
      return eventList;
    }
    // run some checks to make sure I can use this object
    if (!_validEventWithRecurrence()) {
      return eventList;
    }

    Recurrence recurrence = recurrenceRules!;

    DateTime recurrenceDateStart = recurrence.timeStart!;
    DateTime recurrenceDateEnd = recurrence.timeEnd!;

    DateTime eventDateStart = timeStart!;
    DateTime eventDateEnd = timeEnd!;


    int diff = _daysBetween(recurrenceDateStart, recurrenceDateEnd);
    // While this function is expected to be called when the earliest event is created, in case that is not the case, iterate both ways
    // iterate forwards
    for (var i = 0; i < diff; i++) {
      DateTime newEventTimeStartI = eventDateStart.add(Duration(days: i));
      DateTime newEventTimeEndI = eventDateEnd.add(Duration(days: i));

      if (excludeMyself && newEventTimeStartI == eventDateStart) {
        continue;
      }
      if (newEventTimeStartI.compareTo(recurrenceDateEnd) > 0) {
        // newEventTimeStart is after recurrenceDateEnd
        break;
      }

      // now check if the weekday recurrence is right
      if (recurrence.dates![newEventTimeStartI.weekday - 1]) {
        // if yes, create the event
        Event e = Event.clone(this);
        e.timeStart = newEventTimeStartI;
        e.timeEnd = newEventTimeEndI;
        eventList.add(e);
      }
    }
    // iterate backwards
    for (var i = 1; i < diff; i++) {
      DateTime newEventTimeStartD = eventDateStart.subtract(Duration(days: i));
      DateTime newEventTimeEndD = eventDateEnd.subtract(Duration(days: i));

      if (excludeMyself && newEventTimeStartD == eventDateStart) {
        continue;
      }
      if (newEventTimeStartD.compareTo(recurrenceDateStart) < 0) {
        // newEventTimeStart is before recurrenceDateStart
        break;
      }

      // now check if the weekday recurrence is right
      if (recurrence.dates![newEventTimeStartD.weekday - 1]) {
        // if yes, create the event
        Event e = Event.clone(this);
        e.timeStart = newEventTimeStartD;
        e.timeEnd = newEventTimeEndD;
        eventList.add(e);
      }
    }

    return eventList;
  }

  /// grab all related recurring days (timeStarts) from a corresponding event
  ///
  /// to not include the current event, set excludeMyself to true
  List<DateTime> getDatesOfRelatedRecurringEvents({excludeMyself = false}) {
    List<DateTime> dt = [];
    // run checks to make sure i can use this object
    if (!_validEventWithRecurrence()) {
      return dt;
    }

    Recurrence recurrence = recurrenceRules!;

    DateTime recurrenceDateStart = recurrence.timeStart!;
    DateTime recurrenceDateEnd = recurrence.timeEnd!;

    DateTime eventDateStart = timeStart!;


    int diff = _daysBetween(recurrenceDateStart, recurrenceDateEnd);

    // iterate incrementally
    for (var i = 0; i < diff; i++) {
      DateTime curr = eventDateStart.add(Duration(days: i));

      if (excludeMyself && curr == eventDateStart) {
        continue;
      }
      if (curr.compareTo(recurrenceDateEnd) > 0) {
        // newEventTimeStart is after recurrenceDateEnd
        break;
      }
      if (recurrence.dates![curr.weekday - 1]) {
        // valid datetime
        // add
        dt.add(curr);
      }
    }
    // iterate decrementally
    for (var i = 1; i < diff; i++) {
      DateTime curr = eventDateStart.subtract(Duration(days: i));

      if (excludeMyself && curr == eventDateStart) {
        continue;
      }

      if (curr.compareTo(recurrenceDateStart) < 0) {
        // newEventTimeStart is before recurrenceDateStart
        break;
      }
      if (recurrence.dates![curr.weekday - 1]) {
        // valid datetime
        // add
        dt.add(curr);
      }
    }

    return dt;
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
    if (timeCreated != null && timeCreated.runtimeType == Timestamp) {
      timeCreated = timeCreated.toDate();
    }
    if (timeModified != null && timeModified.runtimeType == Timestamp) {
      timeModified = timeModified.toDate();
    }
    if (timeStart != null && timeStart.runtimeType == Timestamp) {
      timeStart = timeStart.toDate();
    }
    if (timeEnd != null && timeEnd.runtimeType == Timestamp) {
      timeEnd = timeEnd.toDate();
    }
    final color = m["hex color"];
    final location = m["location"];
    var tagsList = m["tags"];
    var tags = <String>{};
    for (final tag in tagsList) {
      tags.add(tag);
    }
    final recurrenceRulesObj = m["recurrence rules"];
    final recurrenceDates = recurrenceRulesObj["repeat on days"];
    List<bool>? dates = <bool>[];
    if (recurrenceDates != null) {
      for (final date in recurrenceDates) {
        dates.add(date);
      }
    } else {
      dates = null;
    }
    var recurrenceTimeStart = recurrenceRulesObj["starts on"];
    var recurrenceTimeEnd = recurrenceRulesObj["ends on"];
    final recurrenceID = recurrenceRulesObj["id"];
    if (recurrenceTimeStart != null && recurrenceTimeStart.runtimeType == Timestamp) {
      recurrenceTimeStart = recurrenceTimeStart.toDate();
    }if (recurrenceTimeEnd != null && recurrenceTimeEnd.runtimeType == Timestamp) {
      recurrenceTimeEnd = recurrenceTimeEnd.toDate();
    }
    final recurrenceRules = Recurrence(enabled: recurrenceRulesObj["enabled"], timeStart: recurrenceTimeStart, timeEnd: recurrenceTimeEnd, dates: dates, id: recurrenceID);
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
