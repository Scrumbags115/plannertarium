import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:planner/common/database.dart';
import 'package:planner/firebase_options.dart';
import 'package:planner/models/event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:test/test.dart';

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

class mockDatabaseService extends DatabaseService {
  @override
  final CollectionReference<Map<String, dynamic>> users = FakeFirebaseFirestore().collection("users");
  @override
  late CollectionReference events;

  mockDatabaseService({required super.uid, required mockInstance}) {
    events = users.doc(uid).collection("events");
  }
}

void test_tasks() async {
  DatabaseService db = DatabaseService(uid: "test_user_1000");


}

void main() async {
  final mockInstance = FakeFirebaseFirestore();
  late mockDatabaseService db;
  setUp(() async {
    db = mockDatabaseService(uid: "test_user_1000", mockInstance: mockInstance);
  });

  group("Test creating a bunch of events works", () {
    test("Test creating an event works", () async {
      final Event e = events[0];
      const exampleEventID = "test_event_id_1";
      db.addEvent(exampleEventID, e);
      final result = await db.getEvents(exampleEventID);
      final eventData = result.data()!;
      final Event e2 = Event.fromMap(eventData);
      expect(
        e, e2
      );
    });
  });

  tearDown(() async {

  });
}