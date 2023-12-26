import 'package:flutter_test/flutter_test.dart';
import 'package:planner/common/localTaskDatabase.dart';
import 'package:planner/models/task.dart';

import 'common/mapEquals.dart';

main() async {
  LocalTaskDatabase_setFromTuple();
}

LocalTaskDatabase_setFromTuple() {
  LocalTaskDatabase localDB = LocalTaskDatabase();
  DateTime today = DateTime(2023, 11, 4);
  Task task1 = Task(name: "test task 1");
  Task task2 = Task(name: "test task 2");
  Task task3 = Task(name: "test task 3");
  Map<DateTime, List<Task>> active, delayed, completed;
  active = {
    today: [task1]
  };
  completed = {
    today: [task2]
  };
  delayed = {
    today: [task3]
  };

  group("Test that setting a tuple works as expected", () {
    test("setting tuple", () {
      localDB.setFromTuple((active, completed, delayed));

      expect(myMapEquals(localDB.active, active), true);
      expect(myMapEquals(localDB.completed, completed), true);
      expect(myMapEquals(localDB.delayed, delayed), true);
    });
    test("getTodayTaskList", () {
      List<Task> todayTasks = localDB.getTasksForDate(DateTime(2023, 11, 4));
      expect(todayTasks, active[today]! + completed[today]! + delayed[today]!);
    });
  });
}
