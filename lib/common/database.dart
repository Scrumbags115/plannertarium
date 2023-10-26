import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/recurrence.dart';
import 'package:planner/models/event.dart';

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
  Future<void> addUniqueUserEvent(
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
    // final random = generateRandomString(10);
    var eventID = now.toString();

    addUserEvent(
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
    // final dateTimeNow = DateTime.now();
    // final dateTimeFuture = dateTimeNow.add(const Duration(hours:3));
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
  /// Returns a map, with the eventID being the key and value being a map of the event values
  Future<Map<String, dynamic>> getMapOfUserEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    // Not too sure how to attach a .then function to a future to convert into another future when awaited, so this will just force an await
    Map<String, dynamic> m = {};

    final userEvents =
        await getUserEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
    userEvents.docs.forEach((doc) {
      m[doc.id] = doc.data();
    });

    return m;
  }

  Future<void> _addUserEvent(String eventID, Event e) async {
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

  /// Add/set the user event. The eventID is necessary.
  ///
  /// Every possible option to set is an argument
  /// required: String eventID, String eventName, Set<String> eventTags, num timeStart, num timeEnd
  /// optional: String eventDescription,, String, eventLocation, String eventColor, bool recurrenceEnabled, num recurrenceTimeStart, num recurrenceTimeEnd, List<bool> recurrenceDates
  Future<void> addUserEvent(
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
    Recurrence r = Recurrence(recurrenceEnabled, recurrenceTimeStart,
        recurrenceTimeEnd, recurrenceDates);
    Event e = Event(
        name: eventName,
        tags: eventTags,
        description: eventDescription,
        location: eventLocation,
        color: eventColor,
        timeStart: timeStart,
        timeEnd: timeEnd,
        recurrenceRules: r);
    return await _addUserEvent(eventID, e);
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
      return Task.require(
          name: taskDocument['name'],
          description: taskDocument['description'],
          timeDue: taskDocument['due date'],
          location: taskDocument['location'],
          color: taskDocument['hex color'],
          tags: taskDocument['tags'],
          recurrenceRules: taskDocument['recurrence rules']);
    } catch (e) {
      print("Get Failed");
      return Task(name: "", tags: <String>{});
    }
  }

  Future<void> setUserTasks(String taskID, Task t) async {
    return await users.doc(uid).collection('tasks').doc(taskID).set(t.toMap());
  }
}
