import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner_app/models/task.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // users collection reference
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<Task> getUserTasks(String taskID) async {
    try {
      var taskDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskID)
          .get();
      return Task.require(
          name: taskDocument['name'],
          description: taskDocument['description'],
          timeDue: taskDocument['due date'],
          location: taskDocument['location'],
          color: taskDocument['hex color'],
          tags: taskDocument['tags'],
          recurrenceRules: taskDocument['recurrence rules']);
    } catch (e) {
      print("Get Failed");
      return Task(name: "", tags: <String>{});
    }
  }

  Future<void> setUserTasks(String taskID, Task t) async {
    return await users.doc(uid).collection('tasks').doc(taskID).set(t.toMap());
  }
}
