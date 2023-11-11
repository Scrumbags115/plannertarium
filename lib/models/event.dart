import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/recurrence.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/undertaking.dart';

// import recurrence class here
class Event extends Undertaking{
  late DateTime _timeEnd;

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
      DateTime? timeModified})
      : super() {
    _timeEnd = timeEnd ?? DateTime.now();
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
      required DateTime timeModified})
      : super.requireFields(
            name: name,
            id: id,
            description: description,
            location: location,
            color: color,
            tags: tags,
            recurrenceRules: recurrenceRules,
            timeStart: timeStart,
            timeCreated: timeCreated,
            timeModified: timeModified) {
    _timeEnd = timeEnd;
  }

  
  /// Turn a properly formatted map into an Event class
  /// the map must have all the proper fields
  Event.fromMap(Map<String, dynamic> map, {String? id}) :super.fromMap(map, id: id) {
    _timeEnd = toDateIfTimestamp(map["time end"]);
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

  /// returns a mapping with kv pairs corresponding to Firebase's
  /// possibly a better getter
  @override
  Map<String, dynamic> toMap({keepClasses = false, includeID = false}) {
    Map<String, dynamic> map = super.toMap();
    map['time end'] = timeEnd;
    return map;
  }

  set timeEnd(DateTime newTimeEnd) {
    timeModified = DateTime.now();
    timeEnd = newTimeEnd;
  }

  DateTime get timeEnd => _timeEnd;

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


    int diff = daysBetween(recurrenceDateStart, recurrenceDateEnd);
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


    int diff = daysBetween(recurrenceDateStart, recurrenceDateEnd);

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
