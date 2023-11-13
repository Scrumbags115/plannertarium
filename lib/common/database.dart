import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._internal();

  factory DatabaseService({String? uid}) {
    if (uid != null) {
      uid = uid;
    }
    return _singleton;
  }

  DatabaseService._internal();

  late String userid;
  // TODO: Add caching layer here if time permits

  // users collection reference
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  late CollectionReference events;

  /// Assign UID. This must be ran before any other database function is called else it will crash
  /// 
  /// takes the string ID
  initUID(String uid) {
    userid = uid;
    events = users.doc(userid).collection("events");
  }

  getEvents(String eventID) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection("events")
        .doc(eventID)
        .get(); // turn this into a map of eventID to event objects?
  }

  getAllEvents() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
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

  /// Get all events within a date range
  ///
  /// returns a _JsonQueryDocumentSnapshot of all events within the date range
  Future<QuerySnapshot<Map<String, dynamic>>> getEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    final timestampStart = Timestamp.fromDate(dateStart);
    final timestampEnd = Timestamp.fromDate(dateEnd);
    return users
        .doc(userid)
        .collection("events")
        .where("time start",
            isGreaterThanOrEqualTo: timestampStart,
            isLessThanOrEqualTo: timestampEnd)
        .get();
  }

  /// Get all events within a date range as a Map
  ///
  /// Returns a map, with the eventID being the key and value being an Event class
  Future<Map<String, Event>> getMapOfEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    // Not too sure how to attach a .then function to a future to convert into another future when awaited, so this will just force an await
    Map<String, Event> m = {};

    final userEvents =
        await getEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
    for (var doc in userEvents.docs) {
      m[doc.id] = Event.fromMap(doc.data(), id: doc.id);
    }

    return m;
  }

  // Get list of all events within a date range
  Future<List<Event>> getListOfEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    List<Event> events = [];
    final userEvents =
        await getEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
    for (final doc in userEvents.docs) {
      events.add(Event.fromMap(doc.data(), id: doc.id));
    }
    return events;
  }

  /// Get all events in a day
  ///
  /// returns a QuerySnapshot
  Future<QuerySnapshot<Map<String, dynamic>>> getEventsInDay(
      {required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow.add(const Duration(days: 1));
    return getEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  /// Get all events in a day as a Map
  Future<Map<String, Event>> getMapOfEventsInDay(
      {required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow.add(const Duration(days: 1));
    return getMapOfEventsInDateRange(dateStart: date, dateEnd: tomorrow);
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
        .doc(userid)
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
      var doc = await users.doc(userid).collection("events").doc(oldEventID).get();
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
    if (e.recurrenceRules == null || e.recurrenceRules?.enabled == false) {
      return;
    }
    List<DateTime> dts = e.getDatesOfRelatedRecurringEvents();
    final parentID = e.recurrenceRules!.id;
    for (final dt in dts) {
      // search the database for event on this date
      final Map<String, Event> eventList = await getMapOfEventsInDay(date: dt);
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
      DocumentSnapshot<Map<String, dynamic>> taskDocument = await users.doc(userid).collection('tasks').doc(taskID).get();
      if (taskDocument.exists) {
        return Task.fromMap(taskDocument.data() ?? {"getTask Error":1}, id: taskDocument.id);
      }
    } catch (e) {
      print("Get Failed");
    }
    return Task();
  }
  Future<List<Task>> getTasksOfName(String taskName) async {
    final allTasks = await users.doc(userid).collection("tasks")
            .where("task name",  isEqualTo: taskName).get();
    
    if (allTasks.size == 0) {
      return [];
    }

    List<Task> listOfTasks = [];
    for (var doc in allTasks.docs) {
      Task t = Task.fromMap(doc.data(), id: doc.id);
      listOfTasks.add(t);
    }

    return listOfTasks;
  }
  
  /// Saves a task into the database
  Future<void> setTask(Task t) async {
    return await users.doc(userid).collection('tasks').doc(t.id).set(t.toMap());
  }

  /// Returns a pair of lists of the form (active tasks, completed tasks)
  /// where task.timeCureent is in a date range [dateStart, dateEnd) for all tasks in either list
  Future<(List<Task>, List<Task>)> _getTasksActiveOrCompleted(
      DateTime dateStart, DateTime dateEnd) async {
    assert(dateStart.isBefore(dateEnd));
    Timestamp timestampStart = Timestamp.fromDate(dateStart);
    Timestamp timestampEnd = Timestamp.fromDate(dateEnd);
    QuerySnapshot<Map<String, dynamic>> allTasks = await users
        .doc(userid)
        .collection("tasks")
        .where("current date",
            isGreaterThanOrEqualTo: timestampStart, isLessThan: timestampEnd)
        .get();

    List<Task> activeList = [];
    List<Task> completedList = [];
    for (var doc in allTasks.docs) {
      Task t = Task.fromMap(doc.data(), id: doc.id);
      if (t.completed) {
        completedList.add(t);
      } else {
        activeList.add(t);
      }
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
        .doc(userid)
        .collection("tasks")
        .where("current date", isGreaterThanOrEqualTo: timestampStart)
        // .where("time start",
        //         isLessThan: timestampEnd) // firebase cant do 2 field where()'s
        .get();

    List<Task> delayedList = [];
    for (var doc in candidateTasks.docs) {
      if ((doc['time start'] as Timestamp).toDate().isBefore(dateEnd)) {
        Task t = Task.fromMap(doc.data(), id: doc.id);
        DateTime startDay = getDateOnly(t.timeStart);
        DateTime currentDay = getDateOnly(t.timeCurrent);
        if (startDay.isBefore(currentDay)) {
          delayedList.add(t);
        }
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
    assert(dateStart.isAtSameMomentAs(getDateOnly(dateStart)));
    assert(dateEnd.isAtSameMomentAs(getDateOnly(dateEnd)));

    Map<DateTime, List<Task>> activeMap = {};
    Map<DateTime, List<Task>> completedMap = {};
    Map<DateTime, List<Task>> delayedMap = {};
    for (int i = 0; i < dateEnd.difference(dateStart).inDays; i++) {
      DateTime newDay = getDateOnly(dateStart, offset: i);
      activeMap[newDay] = [];
      completedMap[newDay] = [];
      delayedMap[newDay] = [];
    }

    List<Task> activeList, completedList;
    (activeList, completedList) =
        await _getTasksActiveOrCompleted(dateStart, dateEnd);
    for (Task t in activeList) {
      DateTime currentDay = getDateOnly(t.timeCurrent);
      assert(activeMap[currentDay] != null);
      activeMap[currentDay]!.add(t);
    }
    for (Task t in completedList) {
      DateTime currentDay = getDateOnly(t.timeCurrent);
      assert(completedMap[currentDay] != null);
      completedMap[currentDay]!.add(t);
    }

    List<Task> delayList = await _getTasksDelayed(dateStart, dateEnd);
    for (Task t in delayList) {
      DateTime loopStart =
          t.timeStart.isBefore(dateStart) ? dateStart : t.timeStart;
      DateTime loopEnd =
          t.timeCurrent.isBefore(dateEnd) ? t.timeCurrent : dateEnd;
      loopStart = getDateOnly(loopStart);
      loopEnd = getDateOnly(loopEnd);
      for (int i = 0; i < loopEnd.difference(loopStart).inDays; i++) {
        DateTime date = getDateOnly(loopStart, offset: i);
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
    assert(dateStart.isAtSameMomentAs(getDateOnly(dateStart)));
    assert(dateEnd.isAtSameMomentAs(getDateOnly(dateEnd)));

    Timestamp timestampStart = Timestamp.fromDate(dateStart);
    Timestamp timestampEnd = Timestamp.fromDate(dateEnd);
    QuerySnapshot<Map<String, dynamic>> allTasksDue = await users
        .doc(userid)
        .collection("tasks")
        .where("time due",
            isGreaterThanOrEqualTo: timestampStart, isLessThan: timestampEnd)
        .get();

    Map<DateTime, List<Task>> dueDateMap = {};
    for (int i = 0; i < dateEnd.difference(dateStart).inDays; i++) {
      DateTime newDay = getDateOnly(dateStart, offset: i);
      dueDateMap[newDay] = [];
    }

    for (var doc in allTasksDue.docs) {
      Task t = Task.fromMap(doc.data(), id: doc.id);
      if (t.timeDue == null) continue;
      DateTime dueDate =
          getDateOnly(t.timeDue ?? dateStart); // ?? datestart forced by dart
      dueDateMap[dueDate]?.add(t);
    }

    return dueDateMap;
  }
}
