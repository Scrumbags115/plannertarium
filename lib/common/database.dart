import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/recurrence.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';

class DatabaseService {
  final String uid;

  // users collection reference
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  late CollectionReference events;

  DatabaseService({required this.uid}) {
    events = users.doc(uid).collection("events");
  }

  getUserEvents(String eventID) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("events")
        .doc(eventID)
        .get(); // turn this into a map of eventID to event objects?
  }

  getAllUserEvents() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("events")
        .get();
  }

  /// Adds a unique user event
  ///
  /// Should use this over the other add event functions
  /// Won't need to deal with eventIDs
  /// Each event ID is the current creation timestamp
  Future<void> addUniqueUserEventArgs(
      {required String eventName,
      String eventDescription = "",
      String eventLocation = "",
      String eventColor = "",
      required Set<String> eventTags,
      required DateTime timeStart,
      required DateTime timeEnd,
      bool recurrenceEnabled = false,
      DateTime? recurrenceTimeStart,
      DateTime? recurrenceTimeEnd,
      List<bool> recurrenceDates = const [
        false,
        false,
        false,
        false,
        false,
        false,
        false
      ]}) async {
    final now = DateTime.now();
    var eventID = now.toString();

    addUserEventArgs(
        eventID: eventID,
        eventName: eventName,
        eventDescription: eventDescription,
        eventLocation: eventLocation,
        eventColor: eventColor,
        eventTags: eventTags,
        timeStart: timeStart,
        timeEnd: timeEnd,
        recurrenceEnabled: recurrenceEnabled,
        recurrenceTimeStart: recurrenceTimeStart,
        recurrenceTimeEnd: recurrenceTimeEnd,
        recurrenceDates: recurrenceDates);
  }

  /// Get all events within a date range
  ///
  /// returns a _JsonQueryDocumentSnapshot of all events within the date range
  Future<QuerySnapshot<Map<String, dynamic>>> getUserEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    final timestampStart = Timestamp.fromDate(dateStart);
    final timestampEnd = Timestamp.fromDate(dateEnd);
    return users
        .doc(uid)
        .collection("events")
        .where("event time start",
            isGreaterThanOrEqualTo: timestampStart,
            isLessThanOrEqualTo: timestampEnd)
        .get();
  }

  /// Get all events within a date range as a Map
  ///
  /// Returns a map, with the eventID being the key and value being an Event class
  Future<Map<String, Event>> getMapOfUserEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    // Not too sure how to attach a .then function to a future to convert into another future when awaited, so this will just force an await
    Map<String, Event> m = {};

    final userEvents =
        await getUserEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
    for (var doc in userEvents.docs) {
      m[doc.id] = mapToEvent(doc.data());
    }

    return m;
  }

  // Get list of all events within a date range
  Future<List<Event>> getListOfUserEventsInDateRange({
      required DateTime dateStart, required DateTime dateEnd}) async {
    List<Event> events = [];
    final userEvents = await getUserEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
    for (final doc in userEvents.docs) {
      events.add(mapToEvent(doc.data()));
    }
    return events;
  }

  /// Get all events in a day
  ///
  /// returns a QuerySnapshot
  Future<QuerySnapshot<Map<String, dynamic>>> getUserEventsInDay({required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow.add(const Duration(days: 1));
    return getUserEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  /// Get all events in a day as a Map
  Future<Map<String, Event>> getMapOfUserEventsInDay({required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow.add(const Duration(days: 1));
    return getMapOfUserEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  /// Get list of events in a day
  Future<List<Event>> getListOfUserEventsInDay({
    required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow.add(const Duration(days: 1));
    return getListOfUserEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  Future<void> addUserEvent(String eventID, Event e) async {
    var doc = await events.doc(eventID).get();
    // can't add an event with the same name
    if (doc.exists) {
      throw Future.error("Event ID already exists!");
    }
    return await users
        .doc(uid)
        .collection("events")
        .doc(eventID)
        .set(e.toMap());
  }


  Future<void> addUniqueUserEvent(Event e) async {
    final now = DateTime.now();
    var eventID = now.toString();
    return await addUserEvent(eventID, e);
  }

  /// Add/set the user event. The eventID is necessary.
  ///
  /// Every possible option to set is an argument
  /// required: String eventID, String eventName, Set<String> eventTags, num timeStart, num timeEnd
  /// optional: String eventDescription,, String, eventLocation, String eventColor, bool recurrenceEnabled, num recurrenceTimeStart, num recurrenceTimeEnd, List<bool> recurrenceDates
  Future<void> addUserEventArgs(
      {required String eventID,
      required String eventName,
      String eventDescription = "",
      String eventLocation = "",
      String eventColor = "",
      required Set<String> eventTags,
      required DateTime timeStart,
      required DateTime timeEnd,
      bool recurrenceEnabled = false,
      DateTime? recurrenceTimeStart,
      DateTime? recurrenceTimeEnd,
      List<bool> recurrenceDates = const [
        false,
        false,
        false,
        false,
        false,
        false,
        false
      ]}) async {
    Recurrence r = Recurrence(enabled: recurrenceEnabled, timeStart: recurrenceTimeStart,
        timeEnd: recurrenceTimeEnd, dates: recurrenceDates);
    Event e = Event(
        name: eventName,
        tags: eventTags,
        description: eventDescription,
        location: eventLocation,
        color: eventColor,
        timeStart: timeStart,
        timeEnd: timeEnd,
        recurrenceRules: r);
    return await addUserEvent(eventID, e);
  }

  /// Turn a properly formatted map into an Event class
  ///
  /// the map must have all the proper fields, m should be the return value from firebase as a Map
  /// although I think it should work now if the map has a bunch of datetimes instead
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

  /// Change an option in the event
  ///
  /// needs a event ID and a map of the new option
  /// map ex: {"optionName": "optionValue"}
  Future<void> updateEventOption(
      String eventID, Map<String, dynamic> newOptions) async {
    return events.doc(eventID).update(newOptions);
  }

  Future<void> updateEventName(String oldEventID, String newEventID) async {
    try {
      var doc = await users.doc(uid).collection("events").doc(oldEventID).get();
      Map<String, dynamic> data = {};
      if (doc.data() != null) {
        data = doc.data()!;
      }
      events.doc(newEventID).set(data);
      events.doc(oldEventID).delete();
    } catch (e) {
      return;
    }
  }

  /// Check if an event exists in the db
  Future<bool> checkIfEventExists(String eventID) async {
    // firestore doesn't have a built in function? are we expected to maintain this locally?
    try {
      final event = await events.doc(eventID).get();
      return event.exists;
    } catch (e) {
      return false;
    }
  }

  Future<Task> getUserTasks(String taskID) async {
    try {
      var taskDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskID)
          .get();
      return Task.requireFields(
          name: taskDocument['name'],
          description: taskDocument['description'],
          completed: taskDocument['completed'],
          timeCurrent: taskDocument['current date'],
          timeStart: taskDocument['start date'],
          timeDue: taskDocument['due date'],
          location: taskDocument['location'],
          color: taskDocument['hex color'],
          tags: taskDocument['tags'],
          recurrenceRules: taskDocument['recurrence rules'],
          timeCreated: taskDocument['date created'],
          timeModified: taskDocument['date modified']);
    } catch (e) {
      print("Get Failed");
      return Task(name: "", tags: <String>{});
    }
  }

  Future<void> setUserTasks(String taskID, Task t) async {
    return await users.doc(uid).collection('tasks').doc(taskID).set(t.toMap());
  }

  // add all recurring events in the database
  Future<void> setRecurringEvents(Event e) async {
    List<Event> recurringEvents = e.generateRecurringEvents();
    for (final e in recurringEvents) {
      await addUniqueUserEvent(e);
    }
  }

  // delete all recurring events in the database given a base event
  Future<void> deleteRecurringEvents(Event e) async {
    // guard case, no recurrence then don't do anything
    if (e.recurrenceRules == null || e.recurrenceRules?.enabled == false) {
      return;
    }
    List<DateTime> dts = e.getDatesOfRelatedRecurringEvents();
    final parentID = e.recurrenceRules!.id;
    for (final dt in dts) {
      // search the database for event on this date
      final Map<String, Event> eventList = await getMapOfUserEventsInDay(date: dt);
      // search the corresponding events on that day for the right recurrence ID
      eventList.forEach((docID, event) {
        if (event.recurrenceRules!.id == parentID) {
          // if the recurrence ID matches, delete
          events.doc(docID).delete();
        }
      });
    }
  }
}
