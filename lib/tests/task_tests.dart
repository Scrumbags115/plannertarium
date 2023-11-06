import 'package:flutter/foundation.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';

bool mapEquals(Map<DateTime, List<Task>> m1, Map<DateTime, List<Task>> m2) {
  if (m1.keys.length != m2.keys.length) {
    print('case 1');
    return false;
  }
  for (DateTime key in m1.keys) {
    if (!listEquals(m1[key], m2[key])) {
      print('case 2');
      print("     " + key.toString());
      print("     " + m1.keys.toString());
      print("     " + m2.keys.toString());
      print("     " + m1[key].toString());
      print("     " + m2[key].toString());
      print(listEquals(m1[key], m2[key]));
      return false;
    }
  }
  return true;
}

test_tasks() async {
  print("IN test_tasks");

  await task_new_user();
  
  await task_existing_user();

  print("passed test_tasks :D");
}

Future<void> task_new_user() async {
  print("-----------------------------TEST TASKS NEW USER-----------------------------");
  DateTime today = DateTime(2023, 11, 4);
  String newUser1 = "taskUser"+DateTime.now().millisecondsSinceEpoch.toString();
  print("newUser1 is $newUser1");
  DatabaseService db = DatabaseService(uid: newUser1);

  // Daily view test
  DateTime tomorrow = DateTime(2023, 11, 5);
  Map<DateTime, List<Task>> dailyActive, dailyCompleted, dailyDelayed;
  (dailyActive, dailyCompleted, dailyDelayed) = await db.getTaskMaps(today, tomorrow);
  print("Daily active:    $dailyActive");
  print("Daily completed: $dailyCompleted");
  print("Daily delayed:   $dailyDelayed");
  Map<DateTime, List<Task>> emptyDay = {today: <Task>[]};
  print("Expecting:       $emptyDay");
  assert (mapEquals(dailyActive, emptyDay));
  assert (mapEquals(dailyCompleted, emptyDay));
  assert (mapEquals(dailyDelayed, emptyDay));

  // Weekly view test
  DateTime nextWeek =  DateTime(2023, 11, 11);
  Map<DateTime, List<Task>> weeklyActive, weeklyCompleted, weeklyDelayed;
  (weeklyActive, weeklyCompleted, weeklyDelayed) = await db.getTaskMaps(today, nextWeek);
  print("Weekly active: $weeklyActive");
  print("Weekly completed: $weeklyCompleted");
  print("Weekly delayed: $weeklyDelayed");
  Map<DateTime, List<Task>> emptyWeek = {
                   DateTime(2023, 11, 4):[],
                   DateTime(2023, 11, 5):[], 
                   DateTime(2023, 11, 6):[], 
                   DateTime(2023, 11, 7):[], 
                   DateTime(2023, 11, 8):[], 
                   DateTime(2023, 11, 9):[], 
                   DateTime(2023, 11, 10):[]};
  print("expecting $emptyWeek");
  assert (mapEquals(weeklyActive, emptyWeek));
  assert (mapEquals(weeklyCompleted, emptyWeek));
  assert (mapEquals(weeklyDelayed, emptyWeek));

  // Weekly view test
  DateTime nextMonth =  DateTime(2023, 12, 4);
  Map<DateTime, List<Task>> monthlyActive, monthlyCompleted, monthlyDelayed;
  (monthlyActive, monthlyCompleted, monthlyDelayed) = await db.getTaskMaps(today, nextMonth);
  print("Monthly active: $monthlyActive");
  print("Monthly completed: $monthlyCompleted");
  print("Monthly delayed: $monthlyDelayed");
  Map<DateTime, List<Task>> emptyMonth = {DateTime(2023, 11, 4): [],
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
                    DateTime(2023, 12, 3): []};
  print("expecting $emptyMonth");
  assert (mapEquals(monthlyActive, emptyMonth));
  assert (mapEquals(monthlyCompleted, emptyMonth));
  assert (mapEquals(monthlyDelayed, emptyMonth));

  print("---------------------------------------------Setting db with tasks---------------------------------------------");
  tasks.forEach((t) {db.setTask(t);});

  // Daily
  (dailyActive, dailyCompleted, dailyDelayed) = await db.getTaskMaps(DateTime(2023, 11, 20), DateTime(2023, 11, 21));
  Map<DateTime, List<Task>> dailyActiveExp = {DateTime(2023, 11, 20):[tasks[18]]};
  Map<DateTime, List<Task>> dailyCompExp = {DateTime(2023, 11, 20):[tasks[16], tasks[20]]};
  Map<DateTime, List<Task>> dailyDelayExp = {DateTime(2023, 11, 20):[tasks[13], tasks[4]]};
  print("Daily active found   : $dailyActive");
  print("Daily active expected: $dailyActiveExp");
  print("Daily completed found   : $dailyCompleted");
  print("Daily completed expected: $dailyCompExp");
  print("Daily delayed found   : $dailyDelayed");
  print("Daily delayed expected: $dailyDelayExp");
  assert (mapEquals(dailyActive, dailyActiveExp));
  assert (mapEquals(dailyCompleted, dailyCompExp));
  assert (mapEquals(dailyDelayed, dailyDelayExp));

  // eyeballed the others, seems ok
  // TODO: fill out the rest of these tests

  await db.users.doc(newUser1).delete().then(
      (doc) => print("New User deleted"),
      onError: (e) => print("Error removing user $e"),
    );
    // does not fully delete, do it manually
}

task_existing_user() async {
  print("-----------------------------TEST TASKS EXISTING USER-----------------------------");
  String existingUser1 = "taskExistingUser";
  print("existingUser1 is $existingUser1");
  DatabaseService db = DatabaseService(uid: existingUser1);
  // tasks2.forEach((t) {db.setUserTask(t);});
  // ^ Uncomment above to rewrite database info

  // Weekly
  Map<DateTime, List<Task>> weeklyActive, weeklyCompleted, weeklyDelayed;
  (weeklyActive, weeklyCompleted, weeklyDelayed) = await db.getTaskMaps(DateTime(2023, 11, 6), DateTime(2023, 11, 13));
  Map<DateTime, List<Task>> weeklyActiveExp = {DateTime(2023, 11, 6):[],
                                               DateTime(2023, 11, 7):[],
                                               DateTime(2023, 11, 8):[],
                                               DateTime(2023, 11, 9):[],
                                               DateTime(2023, 11, 10):[],
                                               DateTime(2023, 11, 11):[],
                                               DateTime(2023, 11, 12):[tasks2[7]]};
  Map<DateTime, List<Task>> weeklyCompExp = {DateTime(2023, 11, 6):[],
                                               DateTime(2023, 11, 7):[tasks2[2]],
                                               DateTime(2023, 11, 8):[],
                                               DateTime(2023, 11, 9):[tasks2[3]],
                                               DateTime(2023, 11, 10):[],
                                               DateTime(2023, 11, 11):[],
                                               DateTime(2023, 11, 12):[]};
  Map<DateTime, List<Task>> weeklyDelayExp = {DateTime(2023, 11, 6):[tasks2[2], tasks2[3], tasks2[7], tasks2[6]],
                                               DateTime(2023, 11, 7):[tasks2[3], tasks2[7], tasks2[6]],
                                               DateTime(2023, 11, 8):[tasks2[3], tasks2[7], tasks2[6]],
                                               DateTime(2023, 11, 9):[tasks2[7], tasks2[4], tasks2[6]],
                                               DateTime(2023, 11, 10):[tasks2[7], tasks2[4], tasks2[6]],
                                               DateTime(2023, 11, 11):[tasks2[7], tasks2[4], tasks2[6]],
                                               DateTime(2023, 11, 12):[tasks2[4], tasks2[6]]};
  print("Weekly active found   : $weeklyActive");
  print("Weekly active expected: $weeklyActiveExp");
  print("Weekly completed found   : $weeklyCompleted");
  print("Weekly completed expected: $weeklyCompExp");
  print("Weekly delayed found   : $weeklyDelayed");
  print("Weekly delayed expected: $weeklyDelayExp");
  assert (mapEquals(weeklyActive, weeklyActiveExp));
  assert (mapEquals(weeklyCompleted, weeklyCompExp));
  assert (mapEquals(weeklyDelayed, weeklyDelayExp));
}

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
    Task(),
    Task( // before window
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
  Task( // start before window
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
  Task( // in window
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
  Task( // current after window
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
  Task( // after window
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
  Task( // start before end after window
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
  Task( // spans the window
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
