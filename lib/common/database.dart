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

  Future<DocumentSnapshot<Map<String, dynamic>>> getEvents(String eventID) {
    return users
        .doc(uid)
        .collection("events")
        .doc(eventID)
        .get(); // turn this into a map of eventID to event objects?
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllEvents() {
    return users
        .doc(uid)
        .collection("events")
        .get();
  }

  /// Adds a unique user event
  ///
  /// Should use this over the other add event functions
  /// Won't need to deal with eventIDs
  /// Each event ID is the current creation timestamp
  Future<void> addUniqueEvent(Event event) async {
    final now = DateTime.now();
    var eventID = now.toString();
    addEvent(eventID, event);
  }

  /// Get all events within a date range as a Map
  ///
  /// Returns a map, with the eventID being the key and value being an Event class
  Future<Map<String, Event>> getEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    final timestampStart = Timestamp.fromDate(dateStart);
    final timestampEnd = Timestamp.fromDate(dateEnd);
    // i can't do a composite search as it requires a composite index, which is not built automatically and has a limit in firestore
    // instead, get two query snapshots
    // one for catching time starts and one for catching time ends
    final QuerySnapshot<Map<String, dynamic>> eventsTimeStartRange = await users
        .doc(uid)
        .collection("events")
        .where("event time start",
            isGreaterThanOrEqualTo: timestampStart,
            isLessThanOrEqualTo: timestampEnd)
        .get();

    final QuerySnapshot<Map<String, dynamic>> eventsTimeEndRange = await users
        .doc(uid)
        .collection("events")
        .where("event time end",
            isGreaterThanOrEqualTo: timestampStart,
            isLessThanOrEqualTo: timestampEnd)
        .get();

    // then merge everything into one single collection

    Map<String, Event> m = {};

    for (var doc in eventsTimeStartRange.docs) {
      if (!m.containsKey(doc.id)) {
        m[doc.id] = Event.fromMap(doc.data(), id: doc.id);
      }
    }
    for (var doc in eventsTimeEndRange.docs) {
      // this all is duplicate code; is there a way to chain iterables and do var e in (a, b) or something?
      if (!m.containsKey(doc.id)) {
        m[doc.id] = Event.fromMap(doc.data(), id: doc.id);
      }
    }

    // there's also a risk of a super long event not being caught
    // this is probably expensive but I can't think of a better way to do this, so unless someone else
    // has an idea I'll do this for now
    final QuerySnapshot<Map<String, dynamic>> eventsLessThan = await users
        .doc(uid)
        .collection("events")
        .where("event time start", isLessThan: timestampStart)
        .get();
    final QuerySnapshot<Map<String, dynamic>> eventsGreaterThan = await users
        .doc(uid)
        .collection("events")
        .where("event time start", isGreaterThan: timestampEnd)
        .get();

    // add the intersection of the two sets
    Set<String> setLessThan = {};
    Set<String> setGreaterThan = {};
    // by convert each into a set of IDs
    for (var doc in eventsLessThan.docs) {
      setLessThan.add(doc.id);
    }
    for (var doc in eventsGreaterThan.docs) {
      setGreaterThan.add(doc.id);
    }

    // and checking if the event exists in both sets
    for (var doc in eventsLessThan.docs) {
      if (!m.containsKey(doc.id) &&
          setLessThan.contains(doc.id) &&
          setGreaterThan.contains(doc.id)) {
        m[doc.id] = Event.fromMap(doc.data(), id: doc.id);
      }
    }
    for (var doc in eventsGreaterThan.docs) {
      if (!m.containsKey(doc.id) &&
          setLessThan.contains(doc.id) &&
          setGreaterThan.contains(doc.id)) {
        m[doc.id] = Event.fromMap(doc.data(), id: doc.id);
      }
    }
    return m;
  }

  // Get list of all events within a date range
  Future<List<Event>> getListOfEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    List<Event> events = [];
    final userEvents =
        await getEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
    for (final event in userEvents.values) {
      events.add(event);
    }
    return events;
  }

  /// Get all events in a day
  ///
  /// returns a Map
  Future<Map<String, Event>> getEventsInDay({required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow.add(const Duration(days: 1));
    return getEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  /// Get all events in a day as a Map
  Future<Map<String, Event>> getMapOfEventsInDay(
      {required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow.add(const Duration(days: 1));
    return getEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  /// Get list of events in a day
  Future<List<Event>> getListOfEventsInDay({required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow.add(const Duration(days: 1));
    return getListOfEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  Future<void> addEvent(String eventID, Event event) async {
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
  Future<void> addEventArgs(
      {required String eventID, required Event event}) async {
    return await addEvent(eventID, event);
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
      await addUniqueEvent(e);
    }
  }

  // delete all recurring events in the database given a base event
  Future<void> deleteRecurringEvents(Event e) async {
    // guard case, no recurrence then don't do anything
    if (e.recurrenceRules.enabled == false) {
      return;
    }
    List<DateTime> dts = e.getDatesOfRelatedRecurringEvents();
    final parentID = e.recurrenceRules.id;
    for (final dt in dts) {
      // search the database for event on this date
      final Map<String, Event> eventList = await getMapOfEventsInDay(date: dt);
      // search the corresponding events on that day for the right recurrence ID
      eventList.forEach((docID, event) {
        if (event.recurrenceRules.id == parentID) {
          // if the recurrence ID matches, delete
          events.doc(docID).delete();
        }
      });
    }
  }

  Future<Task> getTask(String taskID) async {
    try {
      var taskDocument =
          await users.doc(uid).collection('tasks').doc(taskID).get();
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
  Future<void> setTask(Task t) async {
    return await users.doc(uid).collection('tasks').doc(t.id).set(t.toMap());
  }

  /// Returns a pair of lists of the form (active tasks, completed tasks)
  /// where task.timeCureent is in a date range [dateStart, dateEnd) for all tasks in either list
  Future<(List<Task>, List<Task>)> _getTasksActiveOrCompleted(
      DateTime dateStart, DateTime dateEnd) async {
    assert(dateStart.isBefore(dateEnd));
    Timestamp timestampStart = Timestamp.fromDate(dateStart);
    Timestamp timestampEnd = Timestamp.fromDate(dateEnd);
    QuerySnapshot<Map<String, dynamic>> allTasks = await users
        .doc(uid)
        .collection("tasks")
        .where("current date",
            isGreaterThanOrEqualTo: timestampStart, isLessThan: timestampEnd)
        .get();

    List<Task> activeList = [];
    List<Task> completedList = [];
    for (var doc in allTasks.docs) {
      Task t = Task.fromMap(doc.data(), id: doc.id);
      if (t.completed)
        completedList.add(t);
      else
        activeList.add(t);
    }

    return (activeList, completedList);
  }

  /// All tasks that have a delay in the window [dateStart, dateEnd)
  /// Returns a list of tasks with delays in the time window in order of current date
  Future<List<Task>> _getTasksDelayed(
      DateTime dateStart, DateTime dateEnd) async {
    assert(dateStart.isBefore(dateEnd));
    Timestamp timestampStart = Timestamp.fromDate(dateStart);
    QuerySnapshot<Map<String, dynamic>> candidateTasks = await users
        .doc(uid)
        .collection("tasks")
        .where("current date", isGreaterThanOrEqualTo: timestampStart)
        // .where("start date",
        //         isLessThan: timestampEnd) // firebase cant do 2 field where()'s
        .get();

    List<Task> delayedList = [];
    for (var doc in candidateTasks.docs) {
      if ((doc['start date'] as Timestamp).toDate().isBefore(dateEnd)) {
        Task t = Task.fromMap(doc.data(), id: doc.id);
        DateTime startDay = _getDateOnly(t.timeStart);
        DateTime currentDay = _getDateOnly(t.timeCurrent);
        if (startDay.isBefore(currentDay)) delayedList.add(t);
      }
    }

    return delayedList;
  }

  /// Returns a 3-tuple of Maps<DateTime, List<Task>> where each map goes from [dateStart, dateEnd)
  /// Values are lists of tasks that are either active, completed, or delayed on a day
  /// Takes the form (ActiveMap, CompletedMap, DelayedMap)
  Future<
      (
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>
      )> getTaskMaps(DateTime dateStart, DateTime dateEnd) async {
    assert(dateStart.isBefore(dateEnd));
    assert(dateStart.isAtSameMomentAs(_getDateOnly(dateStart)));
    assert(dateEnd.isAtSameMomentAs(_getDateOnly(dateEnd)));

    Map<DateTime, List<Task>> activeMap = {};
    Map<DateTime, List<Task>> completedMap = {};
    Map<DateTime, List<Task>> delayedMap = {};
    for (int i = 0; i < dateEnd.difference(dateStart).inDays; i++) {
      DateTime newDay = _getDateOnly(dateStart, offset: i);
      activeMap[newDay] = [];
      completedMap[newDay] = [];
      delayedMap[newDay] = [];
    }

    List<Task> activeList, completedList;
    (activeList, completedList) =
        await _getTasksActiveOrCompleted(dateStart, dateEnd);
    for (Task t in activeList) {
      DateTime currentDay = _getDateOnly(t.timeCurrent);
      assert(activeMap[currentDay] != null);
      activeMap[currentDay]!.add(t);
    }
    for (Task t in completedList) {
      DateTime currentDay = _getDateOnly(t.timeCurrent);
      assert(completedMap[currentDay] != null);
      completedMap[currentDay]!.add(t);
    }

    List<Task> delayList = await _getTasksDelayed(dateStart, dateEnd);
    for (Task t in delayList) {
      DateTime loopStart =
          t.timeStart.isBefore(dateStart) ? dateStart : t.timeStart;
      DateTime loopEnd =
          t.timeCurrent.isBefore(dateEnd) ? t.timeCurrent : dateEnd;
      loopStart = _getDateOnly(loopStart);
      loopEnd = _getDateOnly(loopEnd);
      for (int i = 0; i < loopEnd.difference(loopStart).inDays; i++) {
        DateTime date = _getDateOnly(loopStart, offset: i);
        assert(delayedMap[date] != null);
        delayedMap[date]!.add(t);
      }
    }
    return (activeMap, completedMap, delayedMap);
  }

  /// All tasks that are due in the time window [dateStart, dateEnd)
  /// Returns a map from each day in the window to a list of tasks due that day
  Future<Map<DateTime, List<Task>>> getTasksDue(
      DateTime dateStart, DateTime dateEnd) async {
    assert(dateStart.isBefore(dateEnd));
    assert(dateStart.isAtSameMomentAs(_getDateOnly(dateStart)));
    assert(dateEnd.isAtSameMomentAs(_getDateOnly(dateEnd)));

    Timestamp timestampStart = Timestamp.fromDate(dateStart);
    Timestamp timestampEnd = Timestamp.fromDate(dateEnd);
    QuerySnapshot<Map<String, dynamic>> allTasksDue = await users
        .doc(uid)
        .collection("tasks")
        .where("due date",
            isGreaterThanOrEqualTo: timestampStart, isLessThan: timestampEnd)
        .get();

    Map<DateTime, List<Task>> dueDateMap = {};
    for (int i = 0; i < dateEnd.difference(dateStart).inDays; i++) {
      DateTime newDay = _getDateOnly(dateStart, offset: i);
      dueDateMap[newDay] = [];
    }

    for (var doc in allTasksDue.docs) {
      Task t = Task.fromMap(doc.data(), id: doc.id);
      if (t.timeDue == null) continue;
      DateTime dueDate =
          _getDateOnly(t.timeDue ?? dateStart); // ?? datestart forced by dart
      dueDateMap[dueDate]?.add(t);
    }

    return dueDateMap;
  }

  DateTime _getDateOnly(DateTime dateTime, {int offset = 0}) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + offset);
  }
}
