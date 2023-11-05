import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/recurrence.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';

class DatabaseService {
  final String uid;
  // TODO: Add caching layer here if time permits

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
  Future<void> addUniqueUserEvent(Event event) async {
    final now = DateTime.now();
    var eventID = now.toString();
    addUserEvent(eventID, event);
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

  Future<void> addUserEvent(String eventID, Event event) async {
    var doc = await events.doc(eventID).get();
    // can't add an event with the same name
    if (doc.exists) {
      throw Future.error("Event ID already exists!");
    }
    return await users
        .doc(uid)
        .collection("events")
        .doc(eventID)
        .set(event.toMap());
  }

  /// Add/set the user event. The eventID is necessary.
  ///
  /// Every possible option to set is an argument
  /// required: String eventID, String eventName, Set<String> eventTags, num timeStart, num timeEnd
  /// optional: String eventDescription,, String, eventLocation, String eventColor, bool recurrenceEnabled, num recurrenceTimeStart, num recurrenceTimeEnd, List<bool> recurrenceDates
  Future<void> addUserEventArgs(
      {required String eventID,
        required Event event}) async {
    return await addUserEvent(eventID, event);
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

  Future<Task> getTask(String taskID) async {
    try {
      var taskDocument = await users.doc(uid).collection('tasks').doc(taskID).get();
      return Task.requireFields(
          name: taskDocument['name'],
          id: taskID,
          description: taskDocument['description'],
          completed: taskDocument['completed'],
          color: taskDocument['hex color'],
          location: taskDocument['location'],
          tags: taskDocument['tags'],
          recurrenceRules: taskDocument['recurrence rules'],
          timeStart: taskDocument['start date'],
          timeDue: taskDocument['due date'],
          timeCurrent: taskDocument['current date'],
          timeCreated: taskDocument['date created'],
          timeModified: taskDocument['date modified']);
    } catch (e) {
      print("Get Failed");
      return Task();
    }
  }

  /// Saves a task into the database
  Future<void> setUserTask(Task t) async {
    return await users.doc(uid).collection('tasks').doc(t.id).set(t.toMap());
  }

  /// Returns a pair of lists of the form (active tasks, completed tasks)
  /// where task.timeCureent is in a date range [dateStart, dateEnd) for all tasks in either list
  Future<(List<Task>, List<Task>)> _getTasksActiveOrCompleted(DateTime dateStart, DateTime dateEnd) async {
    assert (dateStart.isBefore(dateEnd));
    final timestampStart = Timestamp.fromDate(dateStart);
    final timestampEnd = Timestamp.fromDate(dateEnd);
    final allTasks = await users.doc(uid).collection("tasks")
            .where("current date",  isGreaterThanOrEqualTo: timestampStart,
                                    isLessThan: timestampEnd).get();
    List<Task> activeList = [];
    List<Task> completedList = [];
    for (var doc in allTasks.docs) {
      Task t = Task.mapToTask(doc.data(), id: doc.id);
      if (t.completed) completedList.add(t);
      else activeList.add(t);
    }
    return (activeList, completedList);
  }

  /// All tasks that have a delay in the window [dateStart, dateEnd)
  /// Returns a list of tasks with delays in the time window in order of ending date
  Future<List<Task>> _getTasksDelayed(DateTime dateStart, DateTime dateEnd) async {
    assert (dateStart.isBefore(dateEnd));
    final timestampStart = Timestamp.fromDate(dateStart);
    List<Task> delayedList = [];
    final candidateTasks = await users.doc(uid).collection("tasks")
        .where("current date",
                isGreaterThanOrEqualTo: timestampStart)
        // .where("start date",
        //         isLessThan: timestampEnd) // stupid internal firebase
        .get();
    for (var doc in candidateTasks.docs) {
      if (DateTime.fromMillisecondsSinceEpoch(doc['start date'].seconds*1000).isBefore(dateEnd)) {
        Task t = Task.mapToTask(doc.data(), id: doc.id);
        DateTime startDay = DateTime(t.timeStart.year, t.timeStart.month, t.timeStart.day);
        DateTime currentDay = DateTime(t.timeCurrent.year, t.timeCurrent.month, t.timeCurrent.day);
        if (startDay.isBefore(currentDay)) 
          delayedList.add(t);
      }
    }

    return delayedList;
  }

  /// Returns a 3-tuple of Maps<DateTime, List<Task>> where each map goes from [dateStart, dateEnd)
  /// Values are lists of tasks that are either active, completed, or delayed on a day
  /// Takes the form (ActiveMap, CompletedMap, DelayedMap)
  Future<(Map<DateTime, List<Task>>, Map<DateTime, List<Task>>, Map<DateTime, List<Task>>)> getTaskMaps(DateTime dateStart, DateTime dateEnd) async {
    assert (dateStart.isBefore(dateEnd));
    assert (dateStart.isAtSameMomentAs(DateTime(dateStart.year, dateStart.month, dateStart.day)));
    assert (dateEnd.isAtSameMomentAs(DateTime(dateEnd.year, dateEnd.month, dateEnd.day)));

    Map<DateTime, List<Task>> activeMap = {};
    Map<DateTime, List<Task>> completedMap = {};
    Map<DateTime, List<Task>> delayedMap = {};
    for (int i = 0; i < dateEnd.difference(dateStart).inDays; i++) {
      DateTime newDay = DateTime(dateStart.year, dateStart.month, dateStart.day+i);
      activeMap[newDay] = [];
      completedMap[newDay] = [];
      delayedMap[newDay] = [];
    }

    List<Task> activeList, completedList;
    (activeList, completedList) = await _getTasksActiveOrCompleted(dateStart, dateEnd);
    for (Task t in activeList) {
      DateTime currentDay = DateTime(t.timeCurrent.year, t.timeCurrent.month, t.timeCurrent.day);
      assert (activeMap[currentDay] != null);
      activeMap[currentDay]!.add(t);
    }
    for (Task t in completedList) {
      DateTime currentDay = DateTime(t.timeCurrent.year, t.timeCurrent.month, t.timeCurrent.day);
      assert (completedMap[currentDay] != null);
      completedMap[currentDay]!.add(t);
    }

    List<Task> delayList = await _getTasksDelayed(dateStart, dateEnd);
    for (Task t in delayList) {
      DateTime loopStart = t.timeStart.isBefore(dateStart) ? dateStart : t.timeStart;
      DateTime loopEnd = t.timeCurrent.isBefore(dateEnd) ? t.timeCurrent : dateEnd;
      loopStart = DateTime(loopStart.year, loopStart.month, loopStart.day);
      loopEnd = DateTime(loopEnd.year, loopEnd.month, loopEnd.day);
      for (int i = 0; i < loopEnd.difference(loopStart).inDays; i++) {
        DateTime date = DateTime(dateStart.year, dateStart.month, dateStart.day+i);
        assert (delayedMap[date] != null);
        delayedMap[date]!.add(t);
      }
    }
    return (activeMap, completedMap, delayedMap);
  }
}
