import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/recurrence.dart';

// import recurrence class here
class Event {
  late String _name = "";
  late final String _id;
  late String _description = "";
  late String _color = "#919191";
  late String _location = "";
  late List<String> _tags = <String>[];
  late Recurrence _recurrenceRules;
  late DateTime _timeStart;
  late DateTime _timeEnd;
  late DateTime _timeCreated;
  late DateTime _timeModified;

  /// Default constructor with minimum required info
  /// Good for if you want to add a new task from user with missing fields
  Event(
      {String name="",
      String? id,
      String description = "",
      String color = "#919191",
      String location = "",
      List<String> tags = const <String>[],
      Recurrence? recurrenceRules,
      DateTime? timeStart,
      DateTime? timeEnd,
      DateTime? timeCreated,
      DateTime? timeModified}) {
    _name = name;
    _id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _description = description;
    _color = color;
    _location = location;
    _tags = tags;
    _recurrenceRules = recurrenceRules ?? Recurrence();
    _timeStart = timeStart ?? DateTime.now();
    _timeEnd = timeEnd ?? DateTime.now();
    _timeCreated = timeCreated ?? DateTime.now();
    _timeModified = timeModified ?? _timeCreated;
  }

  /// Alternate constructor so VSCode autogenerates all fields
  /// Good for reading from database
  Event.requireFields(
      {required String name,
      required String id,
      required String description,
      required String color,
      required String location,
      required List<String> tags,
      required Recurrence recurrenceRules,
      required DateTime timeStart,
      required DateTime timeEnd,
      required DateTime timeCreated,
      required DateTime timeModified}) {
    _name = name;
    _id = id;
    _description = description;
    _color = color;
    _location = location;
    _tags = tags;
    _recurrenceRules = recurrenceRules;
    _timeStart = timeStart;
    _timeEnd = timeEnd;
    _timeCreated = timeCreated;
    _timeModified = timeModified;
  }

  
/// Turn a properly formatted map into an Event class
/// the map must have all the proper fields
Event.fromMap(Map<String, dynamic> m, {String? id}) {
  try {
    _name = m["event name"];
    _id = id ?? m['id'];
    _description = m["description"];
    _color = m["hex color"];
    _location = m["location"];
    _tags = [];
    (m['tags'] as List<String>).forEach((tag) {_tags.add(tag.toString());});
    _recurrenceRules = Recurrence.fromMap(m['recurrence rules']);
    _timeStart = m["event time start"] is Timestamp ? (m["event time start"] as Timestamp).toDate() : m["event time start"];
    _timeEnd = m["event time end"] is Timestamp ? (m["event time end"] as Timestamp).toDate() : m["event time end"];
    _timeCreated = m["date created"] is Timestamp ? (m["date created"] as Timestamp).toDate() : m["date created"];
    _timeModified = m["date modified"] is Timestamp ? (m["date modified"] as Timestamp).toDate() : m["date modified"];
  } catch (e) {
    throw Exception("Given map is malformed!\n$e");
  }
}

  Event.clone(Event e): this(
    name: e.name, 
    id: e.id, 
    description: e.description, 
    color: e.color, 
    location: e.location, 
    tags: e.tags, 
    recurrenceRules: e.recurrenceRules,
    timeStart: e.timeStart, 
    timeEnd: e.timeEnd, 
    timeCreated: e.timeCreated, 
    timeModified: e.timeModified);

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

  set name(String newName) {
    _timeModified = DateTime.now();
    _name = newName;
  }

  String get name => _name;
  
  set id(String newId) {
    _timeModified = DateTime.now();
    _id = newId;
  }

  String get id => _id;

  set description(String newDescription) {
    _timeModified = DateTime.now();
    _description = newDescription;
  }

  String get description => _description;

  set color(String newColor) {
    _timeModified = DateTime.now();
    _color = newColor;
  }

  String get color => _color;

  set location(String newLocation) {
    _timeModified = DateTime.now();
    _location = newLocation;
  }

  String get location => _location;

  set tags(List<String> newTags) {
    _timeModified = DateTime.now();
    _tags = newTags;
  }

  List<String> get tags => _tags;

  set recurrenceRules(Recurrence newRecurrence) {
    _timeModified = DateTime.now();
    _recurrenceRules = newRecurrence;
  }

  Recurrence get recurrenceRules => _recurrenceRules;

  set timeStart(DateTime newTimeStart) {
    _timeModified = DateTime.now();
    _timeStart = newTimeStart;
  }

  DateTime get timeStart => _timeStart;

  set timeEnd(DateTime newTimeEnd) {
    _timeModified = DateTime.now();
    _timeEnd = newTimeEnd;
  }

  DateTime get timeEnd => _timeEnd;

  // Do not want to timeCreated this after the constructor
  get timeCreated => _timeCreated; 

  // Do not want to change timeModified unless modifying a field
  get timeModified => _timeModified; 

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

  @override
  String toString() {
    return "Event($name, $id)";
  }
}
