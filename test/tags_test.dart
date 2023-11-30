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
    tags: ["tag-1", "tag-2"],
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
    tags: ["tag-1", "tag-2"],
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
    tags: ["tag-3"],
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
    tags: [],
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
    includedIDs: {
      "task": ["task-1"]
    },
  ),
  Tag(
    name: "Tag 2",
    id: "tag-2",
    color: "#3366FF",
    includedIDs: {
      "task": ["task-1"]
    },
  ),
  Tag(
    name: "Tag 3",
    id: "tag-3",
    color: "#FF5733",
    includedIDs: {
      "task": ["task-2"]
    },
  ),
];

main() async {
  await tags_AddRemoveTags();
  await tags_AuxilliaryFunctions();
  tags_TagCSVToList();
}

// test adding a tag to a task
tags_AddRemoveTags() async {
  late DatabaseService db;
  late Tag testTag;
  String newUser = "taskUser${DateTime.now().millisecondsSinceEpoch}";

  setUp(() async {
    db = DatabaseService.createTest(
        uid: newUser, firestoreObject: FakeFirebaseFirestore());

    // db.firestoreObject.dump();
    // add tasks to the database
    for (var task in tasks) {
      await db.setTask(task);
    }
    for (var event in events) {
      await db.setEvent(event);
    }

    testTag = Tag(
        name: "test tag", id: "tag-test", color: "#FFFFFF", includedIDs: {});
  });

  group("Tests base task functionality first; set and get methods should work.",
      () {
    // test that adding a tag to a task works
    test("Test that adding and reading a tag to a task works", () async {
      // add a tag to the task
      print("test");
      await db.addTagToTask(tasks[0], testTag);
      var gettingTestTag = await db.getTag(testTag.id);
      print(gettingTestTag == testTag);
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
        tags: ["tag-1", "tag-2"],
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
        tags: ["tag-1", "tag-2"],
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

tags_AuxilliaryFunctions() {
  late DatabaseService db;
  late Tag testTag;
  String newUser = "taskUser${DateTime.now().millisecondsSinceEpoch}";

  setUp(() async {
    db = DatabaseService.createTest(
        uid: newUser, firestoreObject: FakeFirebaseFirestore());

    // add tasks to the database
    for (var task in tasks) {
      await db.setTask(task);
    }
    for (var tag in tags) {
      await db.setTag(tag);
    }

    testTag = Tag(
        name: "test tag", id: "tag-test", color: "#FFFFFF", includedIDs: {});
  });

  test("Test getAllTags", () async {
    var allTags = await db.getAllTags();

    expect(allTags, tags, reason: "getAllTags should return all tags");
  });

  test("Test doesTagExist", () async {
    // check for existing tags
    for (var tag in tags) {
      var res = await db.doesTagExist(tag.name);
      expect(res, true, reason: "Tag should exist");
    }

    // check a random fake tag
    var res = await db.doesTagExist("fake tag");
    expect(res, false, reason: "Tag should not exist");
  });

  test("Test getTasksWithTag", () async {
    // check for existing tags
    var res = await db.getTasksWithTag(tags[0].name);
    print("");
    print("");
    print("");
    print("");
    expect(res, [tasks[0]], reason: "Tag should exist");

    // check a random fake tag
    res = await db.getTasksWithTag("fake tag name");
    expect(res, [], reason: "Tag should not exist");
  });

  test("Test getTagByName", () async {
    var res = await db.getTagByName(tags[0].name);
    expect(res, tags[0], reason: "Tag should exist");

    // res = await db.getTagByName("fake tag name");
    expect(() async => await db.getTagByName("fake tag name"), throwsException,
        reason: "Tag should not exist");
  });
}

tags_TagCSVToList() {
  String noCommas = "tag1";
  String oneComma = "tag1,tag2";
  String commaAndSpace = "tag1, tag2";
  String commaAndMoreSpace = "  tag1  ,  tag2  ";
  String justCommas = ",,,";
  String justSpaces = "    ";
  String justSpacesAndCommas = ", ,, , ,  ,, , ,";
  List<String> noTags = [];
  List<String> justTag1 = ["tag1"];
  List<String> tag1AndTag2 = ["tag1", "tag2"];

  group("Test parsing tag CSV into a list of strings", () {
    test("No commas", () {
      expect(tagCSVToList(noCommas), justTag1);
    });
    test("One comma between two tags", () {
      expect(tagCSVToList(oneComma), tag1AndTag2);
    });
    test("One comma followed by space between two tags", () {
      expect(tagCSVToList(commaAndSpace), tag1AndTag2);
    });
    test("One comma between two tags with extra spaces around each tag", () {
      expect(tagCSVToList(commaAndMoreSpace), tag1AndTag2);
    });
    test("There are only commas entered", () {
      expect(tagCSVToList(justCommas), noTags);
    });
    test("There are only spaces entered", () {
      expect(tagCSVToList(justSpaces), noTags);
    });
    test("There are only spaces and commas entered", () {
      expect(tagCSVToList(justSpacesAndCommas), noTags);
    });
  });
}
