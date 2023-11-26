import 'package:flutter/foundation.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:planner/models/event.dart';
import 'package:planner/models/tag.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

List<Task> tasks = [
  Task(
    name: "Task 1",
    id: "task-1",
    description: "Description for Task 1",
    completed: false,
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 10),
    timeDue: DateTime(2023, 10, 15),
    timeCurrent: DateTime(2023, 10, 12),
    timeCreated: DateTime(2023, 10, 8),
    timeModified: DateTime(2023, 10, 12),
  ),
  Task(
    name: "Task 2",
    id: "task-2",
    description: "Description for Task 2",
    completed: true,
    location: "Location 2",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 5),
    timeDue: DateTime(2023, 11, 10),
    timeCurrent: DateTime(2023, 11, 7),
    timeCreated: DateTime(2023, 11, 4),
    timeModified: DateTime(2023, 11, 7),
  ),
  Task(
    name: "Task 3",
    id: "task-3",
    description: "Description for Task 3",
    completed: false,
    location: "Location 3",
    color: "#FF5733",
    tags: [],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 10),
    timeDue: DateTime(2023, 12, 15),
    timeCurrent: DateTime(2023, 12, 12),
    timeCreated: DateTime(2023, 12, 8),
    timeModified: DateTime(2023, 12, 12),
  ),
];

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
  )
];

List<Tag> tags = [
  Tag(
    name: "Tag 1",
    id: "tag-1",
    color: "#FF5733",
    includedIDs: ["task-1"],
  ),
  Tag(
    name: "Tag 2",
    id: "tag-2",
    color: "#3366FF",
    includedIDs: ["task-1"],
  ),
  Tag(
    name: "Tag 3",
    id: "tag-3",
    color: "#FF5733",
    includedIDs: ["task-2"],
  ),
];

main() async {
  await addRemoveTags();
}

// test adding a tag to a task
addRemoveTags() async {
  late DatabaseService db;
  late DateTime today;
  late Tag testTag;
  String newUser = "taskUser${DateTime.now().millisecondsSinceEpoch}";

  setUp(() async {
    today = DateTime.now();
    db = DatabaseService.createTest(
        uid: newUser, firestoreObject: FakeFirebaseFirestore());

    // db.firestoreObject.dump();
    // add tasks to the database
    for (var task in tasks) {
      await db.setTask(task);
    }

    testTag = Tag(
        name: "test tag", id: "tag-test", color: "#FFFFFF", includedIDs: []);
  });

  group("Tests base task functionality first; set and get methods should work.",
      () {
    // test that adding a tag to a task works
    test("Test that adding and reading a tag to a task works", () async {
      // add a tag to the task
      await db.addTagToTask(tasks[0], testTag);
      var gettingTestTag = await db.getTag(testTag.id);
      expect(gettingTestTag, testTag, reason: "Tag should be added to task");
    });

    // test that removing a tag from a task works
    test("Test that removing a tag from a task works", () async {
      // remove a tag from the task
      await db.removeTagFromTask(tasks[0], testTag);

      // create a dummy task without the test tag
      Task originalTask0 = Task(
        name: "Task 1",
        id: "task-1",
        description: "Description for Task 1",
        completed: false,
        location: "Location 1",
        color: "#FF5733",
        tags: ["Tag1", "Tag2"],
        recurrenceRules: null,
        timeStart: DateTime(2023, 10, 10),
        timeDue: DateTime(2023, 10, 15),
        timeCurrent: DateTime(2023, 10, 12),
        timeCreated: DateTime(2023, 10, 8),
        timeModified: DateTime(2023, 10, 12),
      );

      expect(tasks[0], originalTask0,
          reason: "Tag should be removed from task");
    });
  });

  group(
      "Tests base event functionality first; set and get methods should work.",
      () {
    // test that adding a tag to an event works
    test("Test that adding and reading a tag to a task works", () async {
      // add a tag to the task
      await db.addTagToEvent(events[0], testTag);
      var gettingTestTag = await db.getTag(testTag.id);
      expect(gettingTestTag, testTag, reason: "Tag should be added to event");
    });

    // test that removing a tag from a task works
    test("Test that removing a tag from a event works", () async {
      // remove a tag from the event
      await db.removeTagFromEvent(events[0], testTag);

      // create a dummy task without the test tag
      Event originalEvent0 = Event(
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
      );

      expect(events[0], originalEvent0,
          reason: "Tag should be removed from event");
    });
  });
}
