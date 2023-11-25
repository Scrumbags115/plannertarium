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
  await task_add_tags();
}

// test adding a tag to a task
task_add_tags() async {
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

  // TODO: actually read thru these and make sure they make sense
  // also, add expect()s so they actually test something lol
  group("Tests base functionality first; all methods should work.", () {
    // test that adding a tag to a task works
    test("Test that adding and reading a tag to a task works", () async {
      // add a tag to the task
      await db.addTagToTask(tasks[0], testTag);
      final a = db.firestoreObject.dump();
      // var gettingTestTag = await db.getTag(testTag.id);
      // printOnFailure("gettingTestTag: $gettingTestTag \n\ntestTag: $testTag");
      // expect(gettingTestTag, testTag, reason: "Tag should be added to task");
      print("a" + a);
    });

    // test that removing a tag from a task works
    test("Test that removing a tag from a task works", () async {
      // // remove a tag from the task
      await db.removeTagFromTask(tasks[0], testTag);
    });

    // test that adding a tag to a task works
    test("Test that adding a tag to a task works", () async {
      // // add a tag to the task
      await db.addTagToTask(tasks[0], testTag);
    });

    // test that removing a tag from a task works
    test("Test that removing a tag from a task works", () async {
      // // remove a tag from the task
      await db.removeTagFromTask(tasks[0], testTag);
    });

    // test that adding a tag to a task works
    test("Test that adding a tag to a task works", () async {
      // // add a tag to the task
      await db.addTagToTask(tasks[0], testTag);
    });

    // test that removing a tag from a task works
    test("Test that removing a tag from a task works", () async {
      // // remove a tag from the task
      await db.removeTagFromTask(tasks[0], testTag);
    });

    // test that adding a tag to a task works
    test("Test that adding a tag to a task works", () async {
      // // add a tag to the task
      await db.addTagToTask(tasks[0], testTag);
    });

    // test that removing a tag from a task works
    test("Test that removing a tag from a task works", () async {
      // // remove a tag from the task
      await db.removeTagFromTask(tasks[0], testTag);
    });

    // test that adding a tag to a task works
    test("Test that adding a tag to a task works", () async {
      // // add a tag to the task
      await db.addTagToTask(tasks[0], testTag);
    });
  });

  // test that adding a tag to a task works
  test("Test that adding a tag to a task works", () async {
    // // add a tag to the task
    await db.addTagToTask(tasks[2], testTag);
  });
}
