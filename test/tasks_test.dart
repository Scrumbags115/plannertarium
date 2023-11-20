// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

List<Task> tasks = [
  Task(
    name: "Task 1",
    id: "ID-1",
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
    id: "ID-2",
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
    id: "ID-3",
    description: "Description for Task 3",
    completed: false,
    location: "Location 3",
    color: "#009966",
    tags: ["Tag4"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 15),
    timeDue: DateTime(2023, 12, 20),
    timeCurrent: DateTime(2023, 12, 18),
    timeCreated: DateTime(2023, 12, 12),
    timeModified: DateTime(2023, 12, 18),
  ),
  Task(
    name: "Task 4",
    id: "ID-4",
    description: "Description for Task 4",
    completed: false,
    location: "Location 4",
    color: "#663399",
    tags: ["Tag5"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 15),
    timeDue: DateTime(2023, 10, 20),
    timeCurrent: DateTime(2023, 10, 18),
    timeCreated: DateTime(2023, 10, 12),
    timeModified: DateTime(2023, 10, 18),
  ),
  Task(
    name: "Task 5",
    id: "ID-5",
    description: "Description for Task 5",
    completed: true,
    location: "Location 5",
    color: "#990000",
    tags: ["Tag6"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 20),
    timeDue: DateTime(2023, 11, 25),
    timeCurrent: DateTime(2023, 11, 23),
    timeCreated: DateTime(2023, 11, 18),
    timeModified: DateTime(2023, 11, 23),
  ),
  Task(
    name: "Task 6",
    id: "ID-6",
    description: "Description for Task 6",
    completed: true,
    location: "Location 6",
    color: "#663399",
    tags: ["Tag7"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 10),
    timeDue: DateTime(2023, 12, 15),
    timeCurrent: DateTime(2023, 12, 13),
    timeCreated: DateTime(2023, 12, 8),
    timeModified: DateTime(2023, 12, 13),
  ),
  Task(
    name: "Task 7",
    id: "ID-7",
    description: "Description for Task 7",
    completed: false,
    location: "Location 7",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 20),
    timeDue: DateTime(2023, 10, 25),
    timeCurrent: DateTime(2023, 10, 22),
    timeCreated: DateTime(2023, 10, 18),
    timeModified: DateTime(2023, 10, 22),
  ),
  Task(
    name: "Task 8",
    id: "ID-8",
    description: "Description for Task 8",
    completed: true,
    location: "Location 8",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 15),
    timeDue: DateTime(2023, 11, 20),
    timeCurrent: DateTime(2023, 11, 18),
    timeCreated: DateTime(2023, 11, 14),
    timeModified: DateTime(2023, 11, 18),
  ),
  Task(
    name: "Task 9",
    id: "ID-9",
    description: "Description for Task 9",
    completed: false,
    location: "Location 9",
    color: "#009966",
    tags: ["Tag4"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 25),
    timeDue: DateTime(2023, 12, 30),
    timeCurrent: DateTime(2023, 12, 28),
    timeCreated: DateTime(2023, 12, 22),
    timeModified: DateTime(2023, 12, 28),
  ),
  Task(
    name: "Task 10",
    id: "ID-10",
    description: "Description for Task 10",
    completed: true,
    location: "Location 10",
    color: "#663399",
    tags: ["Tag5"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 25),
    timeDue: DateTime(2023, 10, 30),
    timeCurrent: DateTime(2023, 10, 28),
    timeCreated: DateTime(2023, 10, 22),
    timeModified: DateTime(2023, 10, 28),
  ),
  Task(
    name: "Task 11",
    id: "ID-11",
    description: "Description for Task 11",
    completed: false,
    location: "Location 11",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 10),
    timeDue: DateTime(2023, 11, 15),
    timeCurrent: DateTime(2023, 11, 13),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 13),
  ),
  Task(
    name: "Task 12",
    id: "ID-12",
    description: "Description for Task 12",
    completed: true,
    location: "Location 12",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 5),
    timeDue: DateTime(2023, 12, 10),
    timeCurrent: DateTime(2023, 12, 8),
    timeCreated: DateTime(2023, 12, 4),
    timeModified: DateTime(2023, 12, 8),
  ),
  Task(
    name: "Task 13",
    id: "ID-13",
    description: "Description for Task 13",
    completed: false,
    location: "Location 13",
    color: "#009966",
    tags: ["Tag4"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 15),
    timeDue: DateTime(2023, 10, 20),
    timeCurrent: DateTime(2023, 10, 18),
    timeCreated: DateTime(2023, 10, 12),
    timeModified: DateTime(2023, 10, 18),
  ),
  Task(
    name: "Task 14",
    id: "ID-14",
    description: "Description for Task 14",
    completed: true,
    location: "Location 14",
    color: "#990000",
    tags: ["Tag6"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 19),
    timeDue: DateTime(2023, 11, 21),
    timeCurrent: DateTime(2023, 11, 23),
    timeCreated: DateTime(2023, 11, 18),
    timeModified: DateTime(2023, 11, 23),
  ),
  Task(
    name: "Task 15",
    id: "ID-15",
    description: "Description for Task 15",
    completed: true,
    location: "Location 15",
    color: "#663399",
    tags: ["Tag7"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 10),
    timeDue: DateTime(2023, 12, 15),
    timeCurrent: DateTime(2023, 12, 13),
    timeCreated: DateTime(2023, 12, 8),
    timeModified: DateTime(2023, 12, 13),
  ),
  Task(
    name: "Task 16",
    id: "ID-16",
    description: "Description for Task 16",
    completed: false,
    location: "Location 16",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 20),
    timeDue: DateTime(2023, 10, 25),
    timeCurrent: DateTime(2023, 10, 22),
    timeCreated: DateTime(2023, 10, 18),
    timeModified: DateTime(2023, 10, 22),
  ),
  Task(
    name: "Task 17",
    id: "ID-17",
    description: "Description for Task 17",
    completed: true,
    location: "Location 17",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 20),
    timeDue: DateTime(2023, 11, 20),
    timeCurrent: DateTime(2023, 11, 20),
    timeCreated: DateTime(2023, 11, 14),
    timeModified: DateTime(2023, 11, 18),
  ),
  Task(
    name: "Task 18",
    id: "ID-18",
    description: "Description for Task 18",
    completed: false,
    location: "Location 18",
    color: "#336600",
    tags: ["Tag19"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 5),
    timeDue: DateTime(2023, 12, 10),
    timeCurrent: DateTime(2023, 12, 8),
    timeCreated: DateTime(2023, 12, 4),
    timeModified: DateTime(2023, 12, 8),
  ),
  Task(
    name: "Task 19",
    id: "ID-19",
    description: "Description for Task 19",
    completed: false,
    location: "Location 19",
    color: "#996633",
    tags: ["Tag20"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 10, 30),
    timeDue: DateTime(2023, 11, 21),
    timeCurrent: DateTime(2023, 11, 20),
    timeCreated: DateTime(2023, 10, 26),
    timeModified: DateTime(2023, 11, 2),
  ),
  Task(
    name: "Task 20",
    id: "ID-20",
    description: "Description for Task 20",
    completed: false,
    location: "Location 20",
    color: "#339933",
    tags: ["Tag21"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 12, 20),
    timeDue: DateTime(2023, 12, 25),
    timeCurrent: DateTime(2023, 12, 23),
    timeCreated: DateTime(2023, 12, 18),
    timeModified: DateTime(2023, 12, 23),
  ),
  Task(
    name: "Task 21",
    id: "ID-21",
    description: "Description for Task 21",
    completed: true,
    location: "Location 21",
    color: "#3366FF",
    tags: ["Tag3"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 20),
    timeDue: DateTime(2023, 11, 20),
    timeCurrent: DateTime(2023, 11, 20),
    timeCreated: DateTime(2023, 11, 14),
    timeModified: DateTime(2023, 11, 18),
  ),
];

List<Task> tasks2 = [
  Task(
    // long before window
    name: "MyTask 0",
    id: "MID-0",
    description: "Description for MTask 0",
    completed: false,
    location: "Location 0",
    color: "#FF5733",
    tags: ["Tag0", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(1970),
    timeDue: DateTime(1970),
    timeCurrent: DateTime(1970),
    timeCreated: DateTime(1970),
    timeModified: DateTime(1970),
  ),
  Task(
    // before window
    name: "MyTask 1",
    id: "MID-1",
    description: "Description for MTask 1",
    completed: false,
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 4),
    timeDue: DateTime(2023, 11, 15),
    timeCurrent: DateTime(2023, 11, 5),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 12),
  ),
  Task(
    // start before window
    name: "MyTask 2",
    id: "MID-2",
    description: "Description for MTask 2",
    completed: true,
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 4),
    timeDue: DateTime(2023, 11, 15),
    timeCurrent: DateTime(2023, 11, 7),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 12),
  ),
  Task(
    // in window
    name: "MyTask 3",
    id: "MID-3",
    description: "Description for MTask 3",
    completed: true,
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 6),
    timeDue: DateTime(2023, 11, 15),
    timeCurrent: DateTime(2023, 11, 9),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 12),
  ),
  Task(
    // current after window
    name: "MyTask 4",
    id: "MID-4",
    description: "Description for MTask 4",
    completed: true,
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 9),
    timeDue: DateTime(2023, 11, 15),
    timeCurrent: DateTime(2023, 11, 13),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 12),
  ),
  Task(
    // after window
    name: "MyTask 5",
    id: "MID-5",
    description: "Description for MTask 5",
    completed: false,
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 13),
    timeDue: DateTime(2023, 11, 15),
    timeCurrent: DateTime(2023, 11, 14),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 12),
  ),
  Task(
    // start before end after window
    name: "MyTask 6",
    id: "MID-6",
    description: "Description for MTask 6",
    completed: false,
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 5),
    timeDue: DateTime(2023, 11, 15),
    timeCurrent: DateTime(2023, 11, 13),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 12),
  ),
  Task(
    // spans the window
    name: "MyTask 7",
    id: "MID-7",
    description: "Description for MTask 7",
    completed: false,
    location: "Location 1",
    color: "#FF5733",
    tags: ["Tag1", "Tag2"],
    recurrenceRules: null,
    timeStart: DateTime(2023, 11, 6),
    timeDue: DateTime(2023, 11, 15),
    timeCurrent: DateTime(2023, 11, 12),
    timeCreated: DateTime(2023, 11, 8),
    timeModified: DateTime(2023, 11, 12),
  ),
];

List<Task> tasksDue = [
  Task(
      name: "due1",
      id: '1',
      timeDue: DateTime(2023, 11, 9),
      timeStart: DateTime(2023, 11, 9),
      timeCreated: DateTime(2023, 11, 8)), // Due on 9th
  Task(
      name: "due2",
      id: '2',
      timeDue: DateTime(2023, 11, 9, 23, 59),
      timeStart: DateTime(2023, 11, 9),
      timeCreated: DateTime(2023, 11, 8)), // Due 11:59pm on 9th
  Task(
      name: "due3",
      id: '3',
      timeDue: DateTime(2023, 11, 8, 23, 59),
      timeStart: DateTime(2023, 11, 9),
      timeCreated: DateTime(2023, 11, 8)), // Just before 9th
  Task(
      name: "due4",
      id: '4',
      timeDue: DateTime(2023, 11, 10),
      timeStart: DateTime(2023, 11, 9),
      timeCreated: DateTime(2023, 11, 8)), // Just after 9th
];

bool mapEquals(Map<DateTime, List<Task>> m1, Map<DateTime, List<Task>> m2) {
  if (m1.keys.length != m2.keys.length) {
    // print('unequal keys');
    return false;
  }
  for (DateTime key in m1.keys) {
    if (!setEquals(m1[key]!.toSet(), m2[key]!.toSet())) {
      // print('differing values');
      // print("     $key");
      // print("     ${m1.keys}");
      // print("     ${m2.keys}");
      // print("     ${m1[key]}");
      // print("     ${m2[key]}");
      // print(m1[key]![0].toDetailedString());
      // print(m2[key]![0].toDetailedString());
      // print(m1[key]!.toSet());
      // print("hashcode1 ${m1[key]![0].hashCode}");
      // print(m2[key]!.toSet());
      // print("hashcode2 ${m2[key]![0].hashCode}");
      // print(setEquals(m1[key]!.toSet(), m2[key]!.toSet()));
      return false;
    }
  }
  return true;
}

main() async {
  await task_getSet_new_user();

  await task_getSet_existing_user();

  await task_getTasksDue_gettingTheCorrectListOfTasksForADay();

  await task_delete();

  await task_move();
}

task_getSet_new_user() async {
  late DatabaseService db;
  late DateTime today;
  late List<Task> emptyDay;
  late Map<DateTime, List<Task>> emptyWeek, emptyMonth;
  late List<Task> dailyActiveExp, dailyCompExp, dailyDelayExp;
  String newUser1 = "taskUser${DateTime.now().millisecondsSinceEpoch}";
  setUp(() async {
    today = DateTime(2023, 11, 4);
    db = DatabaseService.createTest(
        uid: newUser1, firestoreObject: FakeFirebaseFirestore());
    emptyDay = [];
    emptyWeek = {
      DateTime(2023, 11, 4): [],
      DateTime(2023, 11, 5): [],
      DateTime(2023, 11, 6): [],
      DateTime(2023, 11, 7): [],
      DateTime(2023, 11, 8): [],
      DateTime(2023, 11, 9): [],
      DateTime(2023, 11, 10): []
    };
    emptyMonth = {
      DateTime(2023, 11, 4): [],
      DateTime(2023, 11, 5): [],
      DateTime(2023, 11, 6): [],
      DateTime(2023, 11, 7): [],
      DateTime(2023, 11, 8): [],
      DateTime(2023, 11, 9): [],
      DateTime(2023, 11, 10): [],
      DateTime(2023, 11, 11): [],
      DateTime(2023, 11, 12): [],
      DateTime(2023, 11, 13): [],
      DateTime(2023, 11, 14): [],
      DateTime(2023, 11, 15): [],
      DateTime(2023, 11, 16): [],
      DateTime(2023, 11, 17): [],
      DateTime(2023, 11, 18): [],
      DateTime(2023, 11, 19): [],
      DateTime(2023, 11, 20): [],
      DateTime(2023, 11, 21): [],
      DateTime(2023, 11, 22): [],
      DateTime(2023, 11, 23): [],
      DateTime(2023, 11, 24): [],
      DateTime(2023, 11, 25): [],
      DateTime(2023, 11, 26): [],
      DateTime(2023, 11, 27): [],
      DateTime(2023, 11, 28): [],
      DateTime(2023, 11, 29): [],
      DateTime(2023, 11, 30): [],
      DateTime(2023, 12, 1): [],
      DateTime(2023, 12, 2): [],
      DateTime(2023, 12, 3): []
    };
    dailyActiveExp = [tasks[18]];
    dailyCompExp = [tasks[16], tasks[20]];
    dailyDelayExp = [tasks[4], tasks[13]];
  });

  group("Test that a new user works as expected", () {
    test("No active, completed, and delayed tasks for a 1 day time window",
        () async {
      List<Task> dailyActive, dailyCompleted, dailyDelayed;
      (dailyActive, dailyCompleted, dailyDelayed) =
          await db.getTaskMapsDay(today);
      expect(dailyActive, emptyDay);
      expect(dailyCompleted, emptyDay);
      expect(dailyDelayed, emptyDay);
    });

    test("No active, completed, and delayed tasks for a 1 week time window",
        () async {
      Map<DateTime, List<Task>> weeklyActive, weeklyCompleted, weeklyDelayed;
      (weeklyActive, weeklyCompleted, weeklyDelayed) =
          await db.getTaskMapsWeek(today);
      assert(mapEquals(weeklyActive, emptyWeek));
      assert(mapEquals(weeklyCompleted, emptyWeek));
      assert(mapEquals(weeklyDelayed, emptyWeek));
    });

    test("No active, completed, and delayed tasks for a 1 month time window",
        () async {
      Map<DateTime, List<Task>> monthlyActive, monthlyCompleted, monthlyDelayed;
      (monthlyActive, monthlyCompleted, monthlyDelayed) =
          await db.getTaskMapsMonth(today);
      expect(mapEquals(monthlyActive, emptyMonth), true);
      expect(mapEquals(monthlyCompleted, emptyMonth), true);
      expect(mapEquals(monthlyDelayed, emptyMonth), true);
    });
  });

  group("Test setTask works for new user", () {
    test("Test that setting a new daily tasks works", () async {
      for (var t in tasks) {
        db.setTask(t);
      }
      List<Task> dailyActive, dailyCompleted, dailyDelayed;
      (dailyActive, dailyCompleted, dailyDelayed) =
          await db.getTaskMapsDay(DateTime(2023, 11, 20));
      expect(dailyActive, dailyActiveExp);
      expect(dailyCompleted, dailyCompExp);
      expect(dailyDelayed, dailyDelayExp);
    });
  });

  tearDown(() async {
    // this may not be necessary as the mocking library means nothing persists between runs
    for (int i = 1; i <= tasks.length; i++) {
      await db.users.doc(newUser1).collection('tasks').doc("ID-$i").delete();
    }
    await db.users.doc(newUser1).delete();
  });
}

task_getSet_existing_user() async {
  late DatabaseService db;
  String existingUser1 = "taskExistingUser";
  late Map<DateTime, List<Task>> weeklyActiveExp, weeklyCompExp, weeklyDelayExp;

  setUp(() async {
    db = DatabaseService.createTest(
        uid: existingUser1, firestoreObject: FakeFirebaseFirestore());
    for (var t in tasks2) {
      await db.setTask(t);
    }
    weeklyActiveExp = {
      DateTime(2023, 11, 6): [],
      DateTime(2023, 11, 7): [],
      DateTime(2023, 11, 8): [],
      DateTime(2023, 11, 9): [],
      DateTime(2023, 11, 10): [],
      DateTime(2023, 11, 11): [],
      DateTime(2023, 11, 12): [tasks2[7]]
    };
    weeklyCompExp = {
      DateTime(2023, 11, 6): [],
      DateTime(2023, 11, 7): [tasks2[2]],
      DateTime(2023, 11, 8): [],
      DateTime(2023, 11, 9): [tasks2[3]],
      DateTime(2023, 11, 10): [],
      DateTime(2023, 11, 11): [],
      DateTime(2023, 11, 12): []
    };
    weeklyDelayExp = {
      DateTime(2023, 11, 6): [tasks2[2], tasks2[3], tasks2[7], tasks2[6]],
      DateTime(2023, 11, 7): [tasks2[3], tasks2[7], tasks2[6]],
      DateTime(2023, 11, 8): [tasks2[3], tasks2[7], tasks2[6]],
      DateTime(2023, 11, 9): [tasks2[7], tasks2[4], tasks2[6]],
      DateTime(2023, 11, 10): [tasks2[7], tasks2[4], tasks2[6]],
      DateTime(2023, 11, 11): [tasks2[7], tasks2[4], tasks2[6]],
      DateTime(2023, 11, 12): [tasks2[4], tasks2[6]]
    };
  });

  group("Getting tasks", () {
    test("Test that getting tasks works correctly for a 1 week window",
        () async {
      Map<DateTime, List<Task>> weeklyActive, weeklyCompleted, weeklyDelayed;
      (weeklyActive, weeklyCompleted, weeklyDelayed) =
          await db.getTaskMapsWeek(DateTime(2023, 11, 6));
      expect(mapEquals(weeklyActive, weeklyActiveExp), true);
      expect(mapEquals(weeklyCompleted, weeklyCompExp), true);
      expect(mapEquals(weeklyDelayed, weeklyDelayExp), true);
    });
  });
}

task_getTasksDue_gettingTheCorrectListOfTasksForADay() async {
  late DatabaseService db;
  String existingUser2 = "taskExistingUser2";
  late Map<DateTime, List<Task>> dailyTasksDueExpected;
  setUp(() async {
    db = DatabaseService.createTest(
        uid: existingUser2, firestoreObject: FakeFirebaseFirestore());
    for (var t in tasksDue) {
      db.setTask(t);
    }
    dailyTasksDueExpected = {
      DateTime(2023, 11, 9): [tasksDue[0], tasksDue[1]],
    };
  });

  group("Test getting correct due dates", () {
    test("Test correct task due on 11/9 in list tasksDue", () async {
      Map<DateTime, List<Task>> dailyTasksDue =
          await db.getTasksDue(DateTime(2023, 11, 9), DateTime(2023, 11, 10));
      expect(mapEquals(dailyTasksDue, dailyTasksDueExpected), true);
    });
  });
}

task_delete() async {
  late DatabaseService db;
  String newUser2 = "taskUser${DateTime.now().millisecondsSinceEpoch}";
  setUp(() {
    db = DatabaseService.createTest(
        uid: newUser2, firestoreObject: FakeFirebaseFirestore());
    for (var t in tasks) {
      db.setTask(t);
    }
  });

  group("Test deleting tasks", () {
    test("Test that delete operations work", () async {
      for (Task t in tasks) {
        db.deleteTask(t);
      }

      Map<DateTime, List<Task>> allActive, allCompleted, allDelayed;
      (allActive, allCompleted, allDelayed) =
          await db.getTaskMaps(DateTime(2023, 10), DateTime(2024));

      for (DateTime date in allActive.keys) {
        expect(listEquals(allActive[date], []), true);
      }
      for (DateTime date in allCompleted.keys) {
        expect(listEquals(allCompleted[date], []), true);
      }
      for (DateTime date in allDelayed.keys) {
        expect(listEquals(allDelayed[date], []), true);
      }

      await db.users.doc(newUser2).delete();
    });
  });
}

task_move() async {
  late DatabaseService db;
  String newUser3 = "newUser3";
  Task t0 = Task(
      name: "only task",
      id: "ONLY",
      timeStart: DateTime(2023, 11, 6),
      timeCurrent: DateTime(2023, 11, 6),
      timeCreated: DateTime(2023, 11, 6),
      timeModified: DateTime(2023, 11, 6));
  Task t6 = Task(
      name: "only task",
      id: "ONLY",
      timeStart: DateTime(2023, 11, 6),
      timeCurrent: DateTime(2023, 11, 12),
      timeCreated: DateTime(2023, 11, 6));
  late Map<DateTime, List<Task>> weeklyActiveExp, weeklyCompExp, weeklyDelayExp;
  setUp(() async {
    db = DatabaseService.createTest(
        uid: newUser3, firestoreObject: FakeFirebaseFirestore());
    // initially active task on 11/6/2023
    db.setTask(t0);
    weeklyActiveExp = {
      DateTime(2023, 11, 6): [],
      DateTime(2023, 11, 7): [],
      DateTime(2023, 11, 8): [],
      DateTime(2023, 11, 9): [],
      DateTime(2023, 11, 10): [],
      DateTime(2023, 11, 11): [],
      DateTime(2023, 11, 12): [t6]
    };
    weeklyCompExp = {
      DateTime(2023, 11, 6): [],
      DateTime(2023, 11, 7): [],
      DateTime(2023, 11, 8): [],
      DateTime(2023, 11, 9): [],
      DateTime(2023, 11, 10): [],
      DateTime(2023, 11, 11): [],
      DateTime(2023, 11, 12): []
    };
    weeklyDelayExp = {
      DateTime(2023, 11, 6): [t6],
      DateTime(2023, 11, 7): [t6],
      DateTime(2023, 11, 8): [t6],
      DateTime(2023, 11, 9): [t6],
      DateTime(2023, 11, 10): [t6],
      DateTime(2023, 11, 11): [t6],
      DateTime(2023, 11, 12): []
    };
  });

  group("Task delays", () {
    test("Delay a task by 1 day each day for a week 11/6 - 11/12", () async {
      // get week of 11/6 - 11/12
      Map<DateTime, List<Task>> weeklyActive, weeklyCompleted, weeklyDelayed;
      (weeklyActive, weeklyCompleted, weeklyDelayed) =
          await db.getTaskMapsWeek(DateTime(2023, 11, 6));

      for (int i = 0; i < 6; i++) {
        weeklyActive[DateTime(2023, 11, 6 + i)]![0].moveToNextDay();
        db.setTask(weeklyActive[DateTime(2023, 11, 6 + i)]![0]);
        (weeklyActive, weeklyCompleted, weeklyDelayed) =
            await db.getTaskMapsWeek(DateTime(2023, 11, 6));
      }

      expect(mapEquals(weeklyActive, weeklyActiveExp), true,
          reason: "$weeklyActive\n!=\n$weeklyActiveExp");
      expect(mapEquals(weeklyCompleted, weeklyCompExp), true);
      expect(mapEquals(weeklyDelayed, weeklyDelayExp), true);
    });
  });
}
