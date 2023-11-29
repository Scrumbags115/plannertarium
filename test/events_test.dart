import 'dart:core';

import 'package:planner/common/database.dart';
import 'package:planner/common/recurrence.dart';
import 'package:planner/models/event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// these are from the task tests
List<Event> events = [
  Event(
    name: "Event 1",
    id: "ID-1",
    description: "Description for Event 1",
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 10),
    timeEnd: DateTime(2023, 10, 15),
    timeCreated: DateTime(2023, 10, 8),
    timeModified: DateTime(2023, 10, 12),
  ),
  Event(
    name: "Event 2",
    id: "ID-2",
    description: "Description for Event 2",
    location: "Location 2",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 5),
    timeEnd: DateTime(2023, 11, 10),
    timeCreated: DateTime(2023, 11, 4),
    timeModified: DateTime(2023, 11, 7),
  ),
  Event(
    name: "Event 3",
    id: "ID-3",
    description: "Description for Event 3",
    location: "Location 3",
    color: "#009966",
    tags: ["Tag4"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 15),
    timeEnd: DateTime(2023, 12, 20),
    timeCreated: DateTime(2023, 12, 12),
    timeModified: DateTime(2023, 12, 18),
  ),
  Event(
    name: "Event 4",
    id: "ID-4",
    description: "Description for Event 4",
    location: "Location 4",
    color: "#663399",
    tags: ["Tag5"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 15),
    timeEnd: DateTime(2023, 10, 20),
    timeCreated: DateTime(2023, 10, 12),
    timeModified: DateTime(2023, 10, 18),
  ),
  Event(
    name: "Event 5",
    id: "ID-5",
    description: "Description for Event 5",
    location: "Location 5",
    color: "#990000",
    tags: ["Tag6"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 20),
    timeEnd: DateTime(2023, 11, 25),
    timeCreated: DateTime(2023, 11, 18),
    timeModified: DateTime(2023, 11, 23),
  ),
  Event(
    name: "Event 6",
    id: "ID-6",
    description: "Description for Event 6",
    location: "Location 6",
    color: "#663399",
    tags: ["Tag7"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 10),
    timeEnd: DateTime(2023, 12, 15),
    timeCreated: DateTime(2023, 12, 8),
    timeModified: DateTime(2023, 12, 13),
  ),
  Event(
    name: "Event 7",
    id: "ID-7",
    description: "Description for Event 7",
    location: "Location 7",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 20),
    timeEnd: DateTime(2023, 10, 25),
    timeCreated: DateTime(2023, 10, 18),
    timeModified: DateTime(2023, 10, 22),
  ),
  Event(
    name: "Event 8",
    id: "ID-8",
    description: "Description for Event 8",
    location: "Location 8",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 15),
    timeEnd: DateTime(2023, 11, 20),
    timeCreated: DateTime(2023, 11, 14),
    timeModified: DateTime(2023, 11, 18),
  ),
  Event(
    name: "Event 9",
    id: "ID-9",
    description: "Description for Event 9",
    location: "Location 9",
    color: "#009966",
    tags: ["Tag4"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 25),
    timeEnd: DateTime(2023, 12, 30),
    timeCreated: DateTime(2023, 12, 22),
    timeModified: DateTime(2023, 12, 28),
  ),
  Event(
    name: "Event 10",
    id: "ID-10",
    description: "Description for Event 10",
    location: "Location 10",
    color: "#663399",
    tags: ["Tag5"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 25),
    timeEnd: DateTime(2023, 10, 30),
    timeCreated: DateTime(2023, 10, 22),
    timeModified: DateTime(2023, 10, 28),
  ),
  Event(
    name: "Event 11",
    id: "ID-11",
    description: "Description for Event 11",
    location: "Location 11",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 10),
    timeEnd: DateTime(2023, 11, 15),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 13),
  ),
  Event(
    name: "Event 12",
    id: "ID-12",
    description: "Description for Event 12",
    location: "Location 12",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 5),
    timeEnd: DateTime(2023, 12, 10),
    timeCreated: DateTime(2023, 12, 4),
    timeModified: DateTime(2023, 12, 8),
  ),
  Event(
    name: "Event 13",
    id: "ID-13",
    description: "Description for Event 13",
    location: "Location 13",
    color: "#009966",
    tags: ["Tag4"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 15),
    timeEnd: DateTime(2023, 10, 20),
    timeCreated: DateTime(2023, 10, 12),
    timeModified: DateTime(2023, 10, 18),
  ),
  Event(
    name: "Event 14",
    id: "ID-14",
    description: "Description for Event 14",
    location: "Location 14",
    color: "#990000",
    tags: ["Tag6"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 19),
    timeEnd: DateTime(2023, 11, 21),
    timeCreated: DateTime(2023, 11, 18),
    timeModified: DateTime(2023, 11, 23),
  ),
  Event(
    name: "Event 15",
    id: "ID-15",
    description: "Description for Event 15",
    location: "Location 15",
    color: "#663399",
    tags: ["Tag7"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 10),
    timeEnd: DateTime(2023, 12, 15),
    timeCreated: DateTime(2023, 12, 8),
    timeModified: DateTime(2023, 12, 13),
  ),
  Event(
    name: "Event 16",
    id: "ID-16",
    description: "Description for Event 16",
    location: "Location 16",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 20),
    timeEnd: DateTime(2023, 10, 25),
    timeCreated: DateTime(2023, 10, 18),
    timeModified: DateTime(2023, 10, 22),
  ),
  Event(
    name: "Event 17",
    id: "ID-17",
    description: "Description for Event 17",
    location: "Location 17",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 20),
    timeEnd: DateTime(2023, 11, 20),
    timeCreated: DateTime(2023, 11, 14),
    timeModified: DateTime(2023, 11, 18),
  ),
  Event(
    name: "Event 18",
    id: "ID-18",
    description: "Description for Event 18",
    location: "Location 18",
    color: "#336600",
    tags: ["Tag19"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 5),
    timeEnd: DateTime(2023, 12, 10),
    timeCreated: DateTime(2023, 12, 4),
    timeModified: DateTime(2023, 12, 8),
  ),
  Event(
    name: "Event 19",
    id: "ID-19",
    description: "Description for Event 19",
    location: "Location 19",
    color: "#996633",
    tags: ["Tag20"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 30),
    timeEnd: DateTime(2023, 11, 21),
    timeCreated: DateTime(2023, 10, 26),
    timeModified: DateTime(2023, 11, 2),
  ),
  Event(
    name: "Event 20",
    id: "ID-20",
    description: "Description for Event 20",
    location: "Location 20",
    color: "#339933",
    tags: ["Tag21"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 20),
    timeEnd: DateTime(2023, 12, 25),
    timeCreated: DateTime(2023, 12, 18),
    timeModified: DateTime(2023, 12, 23),
  ),
  Event(
    name: "Event 21",
    id: "ID-21",
    description: "Description for Event 21",
    location: "Location 21",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 20),
    timeEnd: DateTime(2023, 11, 20),
    timeCreated: DateTime(2023, 11, 14),
    timeModified: DateTime(2023, 11, 18),
  ),
];

const List<bool> RECURRENCE_DATES_MONDAY_WEDNESDAY_FRIDAY = [true, false, true, false, true, false, false];

Event recurringEvent =
Event(
  name: "Recurring Event 1",
  id: "RID-1",
  description: "Description for Recurring Event 21",
  location: "Location R1",
  color: "#3366FF",
  tags: ["Tag3"],
  recurrenceRules: Recurrence.requireFields(enabled: true, timeStart: DateTime(2023, 11, 20), timeEnd: DateTime(2023, 12, 20), dates: RECURRENCE_DATES_MONDAY_WEDNESDAY_FRIDAY, nullOrId: "example recurrence id"),
  timeStart: DateTime(2023, 11, 20),
  timeEnd: DateTime(2023, 11, 21),
  timeCreated: DateTime(2023, 11, 14),
  timeModified: DateTime(2023, 11, 18),
);

/// Check if two mapping of event ids to events are equal
bool eventMapEqual(Map<String, Event> first, Map<String, Event> second) {
  if (first.length != second.length) {
    return false;
  }
  // both maps must be the same length now, so iterate through just one
  for (final String taskName in first.keys) {
    if (first[taskName] != second[taskName]) {
      return false;
    }
  }
  return true;
}

/// turn a list of events into a map of event id to event
Map<String, Event> listOfEventsToMap(List<Event> listOfEvents) {
  Map<String, Event> mapOfEvents = {};

  for (final Event event in listOfEvents) {
    mapOfEvents[event.id] = event;
  }

  return mapOfEvents;
}

void main() async {
  await testEvent_createEventWorks();

  await testEvent_deleteEventWorks();

  await testEvent_recurringEventCreationWorks();

  await testEvent_recurringEventDeletionWorks();
}

testEvent_createEventWorks() async {

  late DatabaseService db;
  setUp(() async {
    db = DatabaseService.createTest(uid: "test_user_1", firestoreObject: FakeFirebaseFirestore());
  });

  group("Test event creation works: ", () {
    test("Test creating an event works", () async {
      final Event event = events[0];
      await db.addEvent(event);
      Event retrievedEvent = await db.getEvent(event.id);
      expect(
          event, retrievedEvent
      );
    });
    test ("Test creating a bunch of events works", () async {
      for (final event in events) {
        await db.addEvent(event);
      }
      final DateTime dateStart = DateTime(2023, 10, 30);
      final DateTime dateEnd = DateTime(2023, 11, 13);
      final retrievedEvents = await db.getEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
      final List<Event> expectedEventList = [events[1], events[2], events[4], events[5], events[7], events[8], events[10], events[11], events[13], events[14], events[16], events[17], events[18], events[19], events[20]];
      final Map<String, Event> expectedEventMap = listOfEventsToMap(expectedEventList);
      expect(eventMapEqual(retrievedEvents, expectedEventMap), true);
    });
  });
}


testEvent_deleteEventWorks() async {
  late DatabaseService db;
  setUp(() async {
    db = DatabaseService.createTest(uid: "test_user_1", firestoreObject: FakeFirebaseFirestore());
    final Event event = events[0];
    await db.addEvent(event);
  });

  group("Test event deletion works: ", () {
    test("Test deleting an event works", () async {
      List<Event> listOfEvents = await db.getAllEvents();
      expect(
          listOfEvents, []
      );
    });
  });
}

/// For a list of events, check each name and ensure it is eventName
bool checkEventNamesAreSame(List<Event> listOfEvents, String eventName) {
  for (final Event event in listOfEvents) {
    if (event.name != eventName) {
      return false;
    }
  }

  return true;
}

/// For a map of events, check each event's timeStart with a list of datetimes
bool checkEventDateTimesAreValid(Map<String, Event> mapOfEvents, List<DateTime> listOfDateTimes) {
  var index = 0;
  for (final event in mapOfEvents.values) {
    if (listOfDateTimes[index] != event.timeStart) {
      return false;
    }
    index++;
  }
  return true;
}

testEvent_recurringEventCreationWorks() async {
  late DatabaseService db;
  setUp(() async {
    db = DatabaseService.createTest(uid: "test_user_12", firestoreObject: FakeFirebaseFirestore());
  });

  group("Test event recurrence creation works: ", () {
    test("Test creating a recurring event works", () async {
      await db.setRecurringEvents(recurringEvent);
      final List<Event> listOfEvents = await db.getAllEvents();
      expect(
          listOfEvents.length, 13
      );
      expect(
        checkEventNamesAreSame(listOfEvents, recurringEvent.name), true
      );
      final Map<String, Event> retrievedEvents = await db.getEventsInDateRange(dateStart: DateTime(2023, 11, 26), dateEnd: DateTime(2023, 12, 2));
      expect(
        retrievedEvents.length, 3
      );
      final List<DateTime> dateTimeList = [DateTime(2023, 11, 27), DateTime(2023, 11, 29), DateTime(2023, 12, 1)];
      expect(checkEventDateTimesAreValid(retrievedEvents, dateTimeList), true);
    });
  });
}


testEvent_recurringEventDeletionWorks() async {
  late DatabaseService db;
  setUp(() async {
    db = DatabaseService.createTest(uid: "test_user_12", firestoreObject: FakeFirebaseFirestore());
    await db.setRecurringEvents(recurringEvent);
  });

  group("Test event recurrence deletion works: ", () {
    test("Test deleting a recurring event deletes rest of recurring events", () async {
      await db.deleteRecurringEvents(recurringEvent);
      final List<Event> retrievedEvents = await db.getAllEvents();

      expect(retrievedEvents, []);
    });

    test("Test deleting a recurring event deletes rest of recurring events when not deleting from the base creation event", () async {
      final List<Event> listOfEvents = await db.getAllEvents();
      final Event event = listOfEvents[0];
      await db.deleteRecurringEvents(event);
      final List<Event> retrievedEventsAfterDeletionCall = await db.getAllEvents();
      expect(retrievedEventsAfterDeletionCall, []);
    });
  });
}

