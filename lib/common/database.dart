import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._internal();
  late String userid;

  // TODO: Add caching layer here if time permits

  // users collection reference
  late CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  factory DatabaseService({String? uid}) {
    return _singleton;
  }

  DatabaseService._internal();

  /// constructor for testing, firestoreObject should be the replacement mocking firestore object
  DatabaseService.createTest({required String uid, required firestoreObject}) {
    userid = uid;
    users = firestoreObject.collection('users');
  }

  /// Assign UID. This must be ran before any other database function is called else it will crash
  /// takes the string ID
  initUID(String uid) {
    userid = uid;
  }

  Future<Event> getEvent(String eventID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> eventDocument =
          await users.doc(userid).collection('events').doc(eventID).get();
      if (eventDocument.exists && eventDocument.data() != null) {
        return Event.fromMap(eventDocument.data() ?? {"getEvent Error": 1},
            id: eventDocument.id);
      }
    } catch (e) {
      rethrow;
    }
    throw Exception("Event not found");
  }

  Future<List<Event>> getAllEvents() async {
    List<Event> allEvents = [];
    final eventDocs = await users.doc(userid).collection("events").get();

    for (var doc in eventDocs.docs) {
      allEvents.add(Event.fromMap(doc.data(), id: doc.id));
    }

    return allEvents;
  }

  /// Put a new event in database. Error if already exists
  Future<void> addEvent(Event event) async {
    var doc = await users.doc(userid).collection("events").doc(event.id).get();
    if (doc.exists) {
      throw Future.error("Event ID already exists!");
    }
    return await users
        .doc(userid)
        .collection("events")
        .doc(event.id)
        .set(event.toMap());
  }

  /// set an event in database
  Future<void> setEvent(Event event) async {
    return await users
        .doc(userid)
        .collection('events')
        .doc(event.id)
        .set(event.toMap());
  }

  /// Get all events within a date range as a Map
  /// Returns a map, with the eventID being the key and value being an Event class
  Future<Map<String, Event>> getEventsInDateRange(
      {required DateTime dateStart, required DateTime dateEnd}) async {
    final timestampStart = Timestamp.fromDate(dateStart);
    final timestampEnd = Timestamp.fromDate(dateEnd);
    // i can't do a composite search as it requires a composite index, which is not built automatically and has a limit in firestore
    // instead, get two query snapshots
    // one for catching time starts and one for catching time ends
    final QuerySnapshot<Map<String, dynamic>> eventsTimeStartInRange =
        await users
            .doc(userid)
            .collection("events")
            .where("time start",
                isGreaterThanOrEqualTo: timestampStart,
                isLessThanOrEqualTo: timestampEnd)
            .get();

    final QuerySnapshot<Map<String, dynamic>> eventsTimeEndInRange = await users
        .doc(userid)
        .collection("events")
        .where("event time end",
            isGreaterThanOrEqualTo: timestampStart,
            isLessThanOrEqualTo: timestampEnd)
        .get();

    // then merge everything into one single collection

    Map<String, Event> eventsMap = {};

    /// if QueryDocumentSnapshot ID field is not in Map
    bool idNotInMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      return !eventsMap.containsKey(doc.id);
    }

    /// For a list of events, check if events of type QueryDocumentSnapshot satisfy a conditional that must take a QueryDocumentSnapshot, if not, add to map
    void checkAndAddEventToMap(
        QuerySnapshot<Map<String, dynamic>> queriedEvents,
        bool Function(QueryDocumentSnapshot<Map<String, dynamic>>)
            conditionalFunction) {
      for (var doc in queriedEvents.docs) {
        if (conditionalFunction(doc)) {
          eventsMap[doc.id] = Event.fromMap(doc.data(), id: doc.id);
        }
      }
    }

    // I can't chain iterables like in python, this is the best I can think of to prevent duplication
    checkAndAddEventToMap(eventsTimeStartInRange, idNotInMap);
    checkAndAddEventToMap(eventsTimeEndInRange, idNotInMap);

    // there's also a risk of a super long event not being caught
    // this is probably expensive but I can't think of a better way to do this, so unless someone else
    // has an idea I'll do this for now
    final QuerySnapshot<Map<String, dynamic>> eventsLessThan = await users
        .doc(userid)
        .collection("events")
        .where("event time start", isLessThan: timestampStart)
        .get();
    final QuerySnapshot<Map<String, dynamic>> eventsGreaterThan = await users
        .doc(userid)
        .collection("events")
        .where("event time start", isGreaterThan: timestampEnd)
        .get();

    // add the intersection of the two sets
    // by converting each into a set of IDs
    // This is a little ugly as a result of Dart disliking forEach
    Set<String> setLessThan = {};
    Set<String> setGreaterThan = {};
    for (var doc in eventsLessThan.docs) {
      setLessThan.add(doc.id);
    }
    for (var doc in eventsGreaterThan.docs) {
      setGreaterThan.add(doc.id);
    }

    /// if QueryDocumentSnapshot in intersection of sets and not already added into map
    bool notInSetOrMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      return idNotInMap(doc) &&
          setLessThan.contains(doc.id) &&
          setGreaterThan.contains(doc.id);
    }

    // and checking if the event exists in both sets
    checkAndAddEventToMap(eventsLessThan, notInSetOrMap);
    checkAndAddEventToMap(eventsGreaterThan, notInSetOrMap);
    return eventsMap;
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
    tomorrow = tomorrow.add(const Duration(days: 1));
    return getEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  /// Get list of events in a day
  Future<List<Event>> getListOfEventsInDay({required DateTime date}) async {
    DateTime tomorrow = date;
    tomorrow = tomorrow.add(const Duration(days: 1));
    return getListOfEventsInDateRange(dateStart: date, dateEnd: tomorrow);
  }

  /// Change an option in the event
  ///
  /// needs a event ID and a map of the new option
  /// map ex: {"optionName": "optionValue"}
  Future<void> updateEventOption(
      String eventID, Map<String, dynamic> newOptions) async {
    return users
        .doc(userid)
        .collection("events")
        .doc(eventID)
        .update(newOptions);
  }

  /// Check if an event exists in the db
  Future<bool> checkIfEventExists(String eventID) async {
    // firestore doesn't have a built in function? are we expected to maintain this locally?
    try {
      final event =
          await users.doc(userid).collection("events").doc(eventID).get();
      return event.exists;
    } catch (e) {
      return false;
    }
  }

  /// add all recurring events in the database
  Future<void> setRecurringEvents(Event e) async {
    List<Event> recurringEvents = e.generateRecurringEvents();
    for (final e in recurringEvents) {
      await addEvent(e);
    }
  }

  /// delete all recurring events in the database given a base event
  Future<void> deleteRecurringEvents(Event e) async {
    // guard case, no recurrence then don't do anything
    if (e.recurrenceRules.enabled == false) {
      return;
    }
    List<DateTime> dts = e.getDatesOfRelatedRecurringEvents();
    final parentID = e.recurrenceRules.id;
    for (final dt in dts) {
      // search the database for event on this date
      final Map<String, Event> eventList = await getEventsInDay(date: dt);
      // search the corresponding events on that day for the right recurrence ID
      eventList.forEach((docID, event) {
        if (event.recurrenceRules.id == parentID) {
          // if the recurrence ID matches, delete
          users.doc(userid).collection("events").doc(docID).delete();
        }
      });
    }
  }

  Future<Task> getTask(String taskID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> taskDocument =
          await users.doc(userid).collection('tasks').doc(taskID).get();
      if (taskDocument.exists) {
        return Task.fromMap(taskDocument.data() ?? {"getTask Error": 1},
            id: taskDocument.id);
      }
    } catch (e) {
      rethrow;
    }
    throw Exception("Task not found");
  }

  Future<List<Task>> getTasksOfName(String taskName) async {
    final allTasks = await users
        .doc(userid)
        .collection("tasks")
        .where("task name", isEqualTo: taskName)
        .get();

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

  /// Deletes a task from the database
  Future<void> deleteTask(Task t) async {
    return await users.doc(userid).collection('tasks').doc(t.id).delete();
  }

  /// Returns a pair of lists of the form (active tasks, completed tasks)
  /// where task.timeCureent is in a date range [dateStart, dateEnd) for all tasks in either list
  Future<(List<Task>, List<Task>)> _getTasksActiveOrCompleted(
      DateTime dateStart, DateTime dateEnd) async {
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
    dateStart = getDateOnly(dateStart);
    dateEnd = getDateOnly(dateEnd);
    verifyDateStartEnd(dateStart, dateEnd);

    Map<DateTime, List<Task>> activeMap = {};
    Map<DateTime, List<Task>> completedMap = {};
    Map<DateTime, List<Task>> delayedMap = {};
    for (int i = 0; i < dateEnd.difference(dateStart).inDays; i++) {
      DateTime newDay = getDateOnly(dateStart, offsetDays: i);
      activeMap[newDay] = [];
      completedMap[newDay] = [];
      delayedMap[newDay] = [];
    }

    List<Task> activeList, completedList;
    (activeList, completedList) =
        await _getTasksActiveOrCompleted(dateStart, dateEnd);

    for (Task t in activeList) {
      DateTime currentDay = getDateOnly(t.timeCurrent);
      if (activeMap[currentDay] == null) {
        continue;
      }
      activeMap[currentDay]!.add(t);
    }
    for (Task t in completedList) {
      DateTime currentDay = getDateOnly(t.timeCurrent);
      if (completedMap[currentDay] == null) {
        continue;
      }
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
        DateTime date = getDateOnly(loopStart, offsetDays: i);
        if (delayedMap[date] == null) {
          continue;
        }
        delayedMap[date]!.add(t);
      }
    }
    return (activeMap, completedMap, delayedMap);
  }

  /// Returns a 3-tuple of List<Task>
  /// Each list has tasks that are either active, completed, or delayed in a time window
  Future<(List<Task>, List<Task>, List<Task>)> getTaskMapsDay(
      DateTime dateStart) async {
    dateStart = getDateOnly(dateStart);

    Map<DateTime, List<Task>> dayActiveMap, dayCompMap, dayDelayMap;
    (dayActiveMap, dayCompMap, dayDelayMap) =
        await getTaskMaps(dateStart, getDateOnly(dateStart, offsetDays: 1));

    return (
      dayActiveMap[dateStart] ?? [],
      dayCompMap[dateStart] ?? [],
      dayDelayMap[dateStart] ?? []
    );
  }

  /// Returns a 3-tuple of Maps<DateTime, List<Task>> where each map goes from 1 week from dateStart
  /// Each map has lists of tasks that are either active, completed, or delayed on a day
  Future<
      (
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>
      )> getTaskMapsWeek(DateTime dateStart) async {
    int daysToNextWeek = 7;
    DateTime oneWeekLater = getDateOnly(dateStart, offsetDays: daysToNextWeek);
    return await getTaskMaps(dateStart, oneWeekLater);
  }

  /// Returns a 3-tuple of Maps<DateTime, List<Task>> where each map goes from 1 month from dateStart
  /// Each map has lists of tasks that are either active, completed, or delayed on a day
  Future<
      (
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>,
        Map<DateTime, List<Task>>
      )> getTaskMapsMonth(DateTime dateStart) async {
    DateTime nextMonth =
        DateTime(dateStart.year, dateStart.month + 1, dateStart.day);
    return getTaskMaps(dateStart, nextMonth);
  }

  /// All tasks that are due in the time window [dateStart, dateEnd)
  /// Returns a map from each day in the window to a list of tasks due that day
  Future<Map<DateTime, List<Task>>> getTasksDue(
      DateTime dateStart, DateTime dateEnd) async {
    dateStart = getDateOnly(dateStart);
    dateEnd = getDateOnly(dateEnd);
    verifyDateStartEnd(dateStart, dateEnd);

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
      DateTime newDay = getDateOnly(dateStart, offsetDays: i);
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

  /// Returns a 3-tuple of List<Task>
  /// Each list has tasks that are either active, completed, or delayed in a time window
  Future<List<Task>> getTasksDueDay(DateTime dateStart) async {
    dateStart = getDateOnly(dateStart);

    Map<DateTime, List<Task>> tasksDueMap;
    tasksDueMap =
        await getTasksDue(dateStart, getDateOnly(dateStart, offsetDays: 1));

    return tasksDueMap[dateStart] ?? [];
  }

  /// Returns a 3-tuple of Maps<DateTime, List<Task>> where each map goes from 1 week from dateStart
  /// Each map has lists of tasks that are either active, completed, or delayed on a day
  Future<Map<DateTime, List<Task>>> getTasksDueWeek(DateTime dateStart) async {
    int daysToNextWeek = 7;
    DateTime oneWeekLater = getDateOnly(dateStart, offsetDays: daysToNextWeek);
    return await getTasksDue(dateStart, oneWeekLater);
  }

  /// Returns a 3-tuple of Maps<DateTime, List<Task>> where each map goes from 1 month from dateStart
  /// Each map has lists of tasks that are either active, completed, or delayed on a day
  Future<Map<DateTime, List<Task>>> getTasksDueMonth(DateTime dateStart) async {
    DateTime nextMonth =
        DateTime(dateStart.year, dateStart.month + 1, dateStart.day);
    return getTasksDue(dateStart, nextMonth);
  }

  /// Get daily and monthly tasks from a day as a single collection for each
  /// return value is (List of daily tasks, map of monthly tasks)
  Future<(List<Task>, Map<DateTime, List<Task>>)> fetchMonthlyTasks(
      DateTime selectedDate) async {
    DateTime dateStart = getDateOnly(selectedDate);
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;
    (activeMap, delayedMap, completedMap) = await getTaskMapsMonth(dateStart);

    var active = activeMap.map((key, value) => MapEntry(getDateOnly(key),
        value)); // Use getDateOnly when setting tasks in the active map
    final todayTasks = active[getDateOnly(selectedDate)] ??
        []; // Use getDateOnly when getting tasks from the active map

    return (todayTasks, active);
  }

  /// Get weekly tasks as a single list
  Future<List<Task>> fetchWeeklyTask() async {
    DateTime today = getDateOnly(DateTime.now());
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;

    // Fetch task maps for the specified week
    (activeMap, delayedMap, completedMap) = await getTaskMapsWeek(today);
    Map<DateTime, List<Task>> dueTasksMap = await getTasksDueWeek(today);

    List<Task> allTasks = [
      ...?activeMap[today],
      ...?delayedMap[today],
      ...?completedMap[today],
      ...?dueTasksMap[today],
    ];
    // print('All tasks for the week: $allTasks');

    return allTasks;
  }

  /// Get daily tasks for a day as a single list
  /// returns a list of tasks
  Future<List<Task>> fetchTodayTasks(DateTime selectedDate) async {
    List<Task> activeList, delayedList, completedList;
    (activeList, delayedList, completedList) =
        await getTaskMapsDay(selectedDate);

    //active = activeMap;
    final todayTasks = [...activeList, ...delayedList, ...completedList];

    return todayTasks;
  }

  // todo: figure out pagination support. from my findings, firestore has poor support for this when also doing queries, and this is only supported with third party services (there are libraries for 3rd parties though), which may not be free :(
  /// Perform a query on a user collection with a certain document key
  ///
  /// Takes a query string and value to limit number of outputs number, user collection key, and document key to search with
  /// Returns found elements that the query is a substring of, with the amount in, with amount specified by limit
  /// This substring search only works if the value of the document key is type string
  /// Note: this is not a true substring search, more of a prefix-substring search. See: https://github.com/Scrumbags115/plannertarium/pull/50#issuecomment-1823732365
  Future<QuerySnapshot<Map<String, dynamic>>> _substringQuery(
      String query, int limit, String collectionKey, String documentKey) async {
    // One downside is that this is apparently case sensitive, we probably can't do much about that unless we create new fields where all text is lowercase/consistent case
    // \uf8ff is used as that is just a large unicode value and tells firestore to use a high upper range
    return await users
        .doc(userid)
        .collection(collectionKey)
        .where(documentKey, isGreaterThanOrEqualTo: query)
        .where(documentKey, isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();
  }

  /// Turns a QuerySnapshot of task documents into a list of tasks
  List<Task> _snapshotToTasks(QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<Task> taskList = [];
    for (final doc in snapshot.docs) {
      taskList.add(Task.fromMap(doc.data(), id: doc.id));
    }
    return taskList;
  }

  /// Turns a QuerySnapshot of event documents into a list of events
  List<Event> _snapshotToEvents(QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<Event> eventList = [];
    for (final doc in snapshot.docs) {
      eventList.add(Event.fromMap(doc.data(), id: doc.id));
    }
    return eventList;
  }

  /// Search function to query a task name
  /// Takes a query string and value to limit number of outputs
  /// Returns list of tasks that the query is a substring in, with amount specified by limit
  Future<List<Task>> searchTaskNames(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedTaskResults =
        await _substringQuery(query, limit, "tasks", "name");
    return _snapshotToTasks(queriedTaskResults);
  }

  /// Search function to query a event name
  /// Takes a query string and value to limit number of outputs
  /// Returns list of events that the query is a substring in, with amount specified by limit
  Future<List<Event>> searchEventNames(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedEventResults =
        await _substringQuery(query, limit, "events", "name");
    // collect outputs
    return _snapshotToEvents(queriedEventResults);
  }

  /// Search function to query a task description
  /// Takes a query string and value to limit number of outputs
  /// Returns list of tasks that the query is a substring in, with amount specified by limit
  Future<List<Task>> searchTaskDescription(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedTaskResults =
        await _substringQuery(query, limit, "tasks", "description");
    return _snapshotToTasks(queriedTaskResults);
  }

  /// Search function to query a event description
  /// Takes a query string and value to limit number of outputs
  /// Returns list of events that the query is a substring in, with amount specified by limit
  Future<List<Event>> searchEventDescription(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedEventResults =
        await _substringQuery(query, limit, "events", "description");
    return _snapshotToEvents(queriedEventResults);
  }

  /// Search function to query a task location
  /// Takes a query string and value to limit number of outputs
  /// Returns list of tasks that the query is a substring in, with amount specified by limit
  Future<List<Task>> searchTaskLocation(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedTaskResults =
        await _substringQuery(query, limit, "tasks", "location");
    return _snapshotToTasks(queriedTaskResults);
  }

  /// Search function to query a event location
  /// Takes a query string and value to limit number of outputs
  /// Returns list of events that the query is a substring in, with amount specified by limit
  Future<List<Event>> searchEventLocation(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedEventResults =
        await _substringQuery(query, limit, "events", "location");
    return _snapshotToEvents(queriedEventResults);
  }

  /// Query for tags with array-contains
  /// takes a query, limit, collection key
  Future<QuerySnapshot<Map<String, dynamic>>> _tagQuery(
      String query, int limit, String collectionKey) async {
    return await users
        .doc(userid)
        .collection(collectionKey)
        .where('tags', arrayContains: query)
        .limit(limit)
        .get();
  }

  /// Search function to query task tags
  /// Takes a query string and value to limit number of outputs
  /// Returns list of tasks that the query is in the tags of (not substring), with amount specified by limit
  Future<List<Task>> searchTaskTags(String query, int limit) async {
    // tags are a little weird since they are stored as a list, and firestore doesn't support substring searching for complex types
    // seems like the best they have available without 3rd party solutions is array-contains
    final QuerySnapshot<Map<String, dynamic>> queriedTaskResults =
        await _tagQuery(query, limit, "tasks");
    return _snapshotToTasks(queriedTaskResults);
  }

  /// Search function to query event tags
  /// Takes a query string and value to limit number of outputs
  /// Returns list of events that the query is in the tags of (not substring), with amount specified by limit
  Future<List<Event>> searchEventTags(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedEventResults =
        await _tagQuery(query, limit, "events");
    return _snapshotToEvents(queriedEventResults);
  }
}
