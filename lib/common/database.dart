import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/task.dart';
import 'package:planner/models/tag.dart';
import 'package:planner/models/undertaking.dart';

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._internal();
  late String userid;
  late FirebaseFirestore fs;

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
    fs = firestoreObject;
  }

  get firestoreObject => fs;

  /// Assign UID. This must be ran before any other database function is called else it will crash
  /// takes the string ID
  initUID(String uid) {
    userid = uid;
  }

////////////////////////////////////////////////////

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

////////////////////////////////////////////////////

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

////////////////////////////////////////////////////

  // Updates an existing tag, or creates a new tag if it doesn't exist
  // Takes in a Tag object
  Future<void> setTag(Tag tag) async {
    return await users
        .doc(userid)
        .collection("tags")
        .doc(tag.id)
        .set(tag.toMap());
  }

  // Get a tag from the database by ID
  Future<Tag> getTag(String tagID) async {
    DocumentSnapshot<Map<String, dynamic>> tagDocument =
        await users.doc(userid).collection('tags').doc(tagID).get();
    if (tagDocument.exists) {
      var tagMap = tagDocument.data() ?? {"getTag Error": 1};
      return Tag.fromMap(tagMap);
    } else {
      throw Exception("Tag not found");
    }
  }

  // Get a tag from the database by name
  Future<Tag> getTagByName(String tagName) async {
    try {
      // get all tags with the name tagName
      var query = await users
          .doc(userid)
          .collection('tags')
          .where("name", isEqualTo: tagName)
          .get();

      // if there are any tags with the name tagName, return true
      if (query.docs.isNotEmpty) {
        List<String> pleaseWorkIDs = [];
        for (var id in query.docs[0].data()["includedIDs"]) {
          pleaseWorkIDs.add(id.toString());
        }

        Tag out = Tag(
          name: query.docs[0].data()["name"],
          id: query.docs[0].data()["id"],
          color: query.docs[0].data()["color"],
          includedIDs: pleaseWorkIDs,
        );
        return out;
      } else {
        // otherwise, return false
        throw Exception("Tag not found");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Returns whether or not a tag with name tagName exists
  Future<bool> doesTagExist(String tagName) async {
    try {
      // get all tags with the name tagName
      var query = await users
          .doc(userid)
          .collection('tags')
          .where("name", isEqualTo: tagName)
          .get();

      // if there are any tags with the name tagName, return true
      if (query.docs.isNotEmpty) {
        return true;
      } else {
        // otherwise, return false
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get ID of all Undertakings with the given tag
  /// Returns a list of IDs
  /// Returns empty list if tag doesn't exist
  Future<List<String>> getUndertakingsWithTag(String tagName) async {
    List<String> out = [];
    Tag tag;

    try {
      // attempt to get tag
      tag = await getTagByName(tagName);
    } catch (e) {
      // if tag doesn't exist, return empty list
      return out;
    }

    return tag.includedIDs;
  }

  /// Get all tags in the database
  /// Returns a list of maps, where each map is a tag and its data:
  /// {"name": "tagName", "id": "tagID", "color": "tagColor", "includedIDs": ["taskID1", "taskID2", ...]}
  /// (includedIDs is a list of task IDs)
  Future<List<Tag>> getAllTags() async {
    List<Tag> allTags = [];
    final tagDocs = await users.doc(userid).collection("tags").get();

    for (var doc in tagDocs.docs) {
      allTags.add(Tag.fromMap(doc.data()));
    }

    return allTags;
  }

  /// Add an existing tag to an undertaking
  /// Adds the task ID to the tag, and adds the tag ID to the task
  Future<void> addTagToUndertaking(Undertaking ut, Tag tag) async {
    // add undertaking ID to task
    ut.tags.add(tag.id);
    // add undertaking ID to tag
    tag.includedIDs.add(ut.id);

    // update undertaking
    if (ut is Task) {
      await setTask(ut);
    } else if (ut is Event) {
      await setEvent(ut);
    } else {
      throw Exception("Undertaking is neither a task nor an event! (somehow)");
    }

    // update tag
    await setTag(tag);
  }

  /// Just a wrapper for addTagToUndertaking()
  Future<void> addTagToTask(Task task, Tag tag) async {
    await addTagToUndertaking(task, tag);
  }

  /// Just a wrapper for addTagToUndertaking()
  /// TODO: Add a check to make sure that the event is not recurring
  Future<void> addTagToEvent(Event event, Tag tag) async {
    await addTagToUndertaking(event, tag);
  }

  /// Remove a tag from an undertaking
  /// Removes the task ID from the tag, and removes the tag ID from the task
  /// If the tag has no more tasks, delete the tag
  Future<void> removeTagFromUndertaking(Undertaking utaken, Tag tag) async {
    // remove undertaking ID from task
    utaken.tags.remove(tag.id);
    // remove undertaking ID from tag
    tag.includedIDs.remove(utaken.id);

    // update task
    if (utaken is Task) {
      await setTask(utaken);
    } else if (utaken is Event) {
      await setEvent(utaken);
    } else {
      throw Exception("Undertaking is neither a task nor an event! (somehow)");
    }

    // update tag
    await setTag(tag);

    // delete tag if it has no more tasks
    if (tag.includedIDs.isEmpty) {
      await deleteTag(tag);
    }
  }

  /// Just a wrapper for removeTagFromUndertaking()
  /// TODO: Add a check to make sure that the event is not recurring
  Future<void> removeTagFromEvent(Event event, Tag tag) async {
    await removeTagFromUndertaking(event, tag);
  }

  /// Just a wrapper for removeTagFromUndertaking()
  Future<void> removeTagFromTask(Task task, Tag tag) async {
    await removeTagFromUndertaking(task, tag);
  }

  /// Delete a tag from the database
  /// DOES NOT ALTER EXISTING TASKS, E.G.
  /// IF A TASK HAS A TAG THAT IS DELETED, THE TASK WILL STILL HAVE THE TAG
  /// USE removeTagFromUndertaking() TO REMOVE A TAG FROM A TASK
  /// Returns true if tag was deleted, false if tag doesn't exist
  Future<bool> deleteTag(Tag tag) async {
    // check if tag exists
    final tagDocs = await users
        .doc(userid)
        .collection("tags")
        .where("name", isEqualTo: tag.name)
        .get();

    if (tagDocs.docs.isEmpty) {
      return false;
    }

    // delete tag
    await users.doc(userid).collection("tags").doc(tagDocs.docs[0].id).delete();
    return true;
  }

  ///////////////////////////////////////////////////////////////////////

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

  /// Turns a QuerySnapshot of tasks into a map of tasks
  Map<String, Task> _collectTasks(
      QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    Map<String, Task> taskMap = {};
    for (final doc in querySnapshot.docs) {
      taskMap[doc.id] = Task.fromMap(doc.data(), id: doc.id);
    }
    return taskMap;
  }

  /// Turns a QuerySnapshot of tasks into a map of tasks
  Map<String, Event> _collectEvents(
      QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    Map<String, Event> taskMap = {};
    for (final doc in querySnapshot.docs) {
      taskMap[doc.id] = Event.fromMap(doc.data(), id: doc.id);
    }
    return taskMap;
  }

  /// Search function to query a task name
  ///
  /// Takes a query string and value to limit number of outputs
  /// Returns tasks that the query is a substring in, with amount specified by limit
  /// Return format is map of tasks
  Future<Map<String, Task>> searchTaskNames(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedTaskResults =
        await _substringQuery(query, limit, "tasks", "name");
    // collect outputs
    return _collectTasks(queriedTaskResults);
  }

  /// Search function to query a event name
  ///
  /// Takes a query string and value to limit number of outputs
  /// Returns events that the query is a substring in, with amount specified by limit
  /// Return format is map of events
  Future<Map<String, Event>> searchEventNames(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedEventResults =
        await _substringQuery(query, limit, "events", "name");
    // collect outputs
    return _collectEvents(queriedEventResults);
  }

  /// Search function to query a task description
  ///
  /// Takes a query string and value to limit number of outputs
  /// Returns tasks that the query is a substring in, with amount specified by limit
  /// Return format is map of tasks
  Future<Map<String, Task>> searchTaskDescription(
      String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedTaskResults =
        await _substringQuery(query, limit, "tasks", "description");
    // collect outputs
    return _collectTasks(queriedTaskResults);
  }

  /// Search function to query a event description
  ///
  /// Takes a query string and value to limit number of outputs
  /// Returns events that the query is a substring in, with amount specified by limit
  /// Return format is map of events
  Future<Map<String, Event>> searchEventDescription(
      String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedEventResults =
        await _substringQuery(query, limit, "events", "description");
    // collect outputs
    return _collectEvents(queriedEventResults);
  }

  /// Search function to query a task location
  ///
  /// Takes a query string and value to limit number of outputs
  /// Returns tasks that the query is a substring in, with amount specified by limit
  /// Return format is map of tasks
  Future<Map<String, Task>> searchTaskLocation(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedTaskResults =
        await _substringQuery(query, limit, "tasks", "location");
    // collect outputs
    return _collectTasks(queriedTaskResults);
  }

  /// Search function to query a event location
  ///
  /// Takes a query string and value to limit number of outputs
  /// Returns events that the query is a substring in, with amount specified by limit
  /// Return format is map of events
  Future<Map<String, Event>> searchEventLocation(
      String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedEventResults =
        await _substringQuery(query, limit, "events", "location");
    // collect outputs
    return _collectEvents(queriedEventResults);
  }

  /// Query for tags with array-contains
  ///
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
  ///
  /// Takes a query string and value to limit number of outputs
  /// Returns tasks that the query is in the tags of (not substring), with amount specified by limit
  /// Return format is map of tasks
  Future<Map<String, Task>> searchTaskTags(String query, int limit) async {
    // tags are a little weird since they are stored as a list, and firestore doesn't support substring searching for complex types
    // seems like the best they have available without 3rd party solutions is array-contains
    final QuerySnapshot<Map<String, dynamic>> queriedTaskResults =
        await _tagQuery(query, limit, "tasks");
    // collect outputs
    return _collectTasks(queriedTaskResults);
  }

  /// Search function to query event tags
  ///
  /// Takes a query string and value to limit number of outputs
  /// Returns events that the query is in the tags of (not substring), with amount specified by limit
  /// Return format is map of events
  Future<Map<String, Event>> searchEventTags(String query, int limit) async {
    final QuerySnapshot<Map<String, dynamic>> queriedEventResults =
        await _tagQuery(query, limit, "events");
    // collect outputs
    return _collectEvents(queriedEventResults);
  }
}
