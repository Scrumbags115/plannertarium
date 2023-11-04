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
  Future<(List<Task>, List<Task>)> _getTasksActiveOrCompletedInRange(DateTime dateStart, DateTime dateEnd) async {
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
  Future<List<Task>> _getTasksDelayedInRange(DateTime dateStart, DateTime dateEnd) async {
    assert (dateStart.isBefore(dateEnd));
    final timestampStart = Timestamp.fromDate(dateStart);
    final timestampEnd = Timestamp.fromDate(dateEnd);
    List<Task> delayedList = [];
    final candidateTasks = await users
        .doc(uid)
        .collection("tasks")
        .where("current date",
            isGreaterThanOrEqualTo: timestampStart)
        .where("start date",
            isLessThan: timestampEnd)
        .get();

    for (var doc in candidateTasks.docs) {
      Task t = Task.mapToTask(doc.data(), id: doc.id);
      DateTime startDay = DateTime(t.timeStart.year, t.timeStart.month, t.timeStart.day);
      DateTime currentDay = DateTime(t.timeCurrent.year, t.timeCurrent.month, t.timeCurrent.day);
      if (startDay != currentDay) {
          delayedList.add(t);
      }
    }

    return delayedList;
  }

  /// Adds all tasks that have a delay in the time window into the map organized by day
  Future<Map<DateTime, List<Task>>> _getTaskDelaysByDay(Map<DateTime, List<Task>> map, DateTime dateStart, DateTime dateEnd) async {
    assert (dateStart.isBefore(dateEnd));
    List<Task> delayList = await _getTasksDelayedInRange(dateStart, dateEnd);

    for (Task t in delayList) {
      DateTime loopStart = t.timeStart.isBefore(dateStart) ? dateStart : t.timeStart;
      DateTime loopEnd = t.timeCurrent.isBefore(dateEnd) ? t.timeCurrent : dateEnd;
      loopStart = DateTime(loopStart.year, loopStart.month, loopStart.day);
      loopEnd = DateTime(loopEnd.year, loopEnd.month, loopEnd.day);
      for (int i = 0; i < loopEnd.difference(loopStart).inDays; i++) {
        DateTime date = dateStart.add(Duration(days: i));
        assert (map[date] != null);
        map[date]!.add(t);
      }
    }

    return map;
  }

  /// Returns a 3-tuple of Maps<DateTime, List<Task>> where each map goes from [dateStart, dateEnd)
  /// Values are lists of tasks that are either active, completed, or delayed on a day
  /// Takes the form (ActiveMap, CompletedMap, DelayedMap)
  Future<(Map<DateTime, List<Task>>, Map<DateTime, List<Task>>, Map<DateTime, List<Task>>)> getTaskMap(DateTime dateStart, DateTime dateEnd) async {
    assert (dateStart.isBefore(dateEnd));
    assert (dateStart.isAtSameMomentAs(DateTime(dateStart.year, dateStart.month, dateStart.day)));
    assert (dateEnd.isAtSameMomentAs(DateTime(dateEnd.year, dateEnd.month, dateEnd.day)));

    Map<DateTime, List<Task>> activeMap = {};
    Map<DateTime, List<Task>> completedMap = {};
    Map<DateTime, List<Task>> delayedMap = {};
    for (int i = 0; i < dateEnd.difference(dateStart).inDays; i++) {
      DateTime newDay = dateStart.add(Duration(days: i));
      activeMap[newDay] = [];
      completedMap[newDay] = [];
      delayedMap[newDay] = [];
    }

    delayedMap = await _getTaskDelaysByDay(delayedMap, dateStart, dateEnd);

    List<Task> activeList, completedList;
    (activeList, completedList) = await _getTasksActiveOrCompletedInRange(dateStart, dateEnd);

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

    return (activeMap, completedMap, delayedMap);
  }

}
