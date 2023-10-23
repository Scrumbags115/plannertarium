import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner_app/models/task.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // users collection reference
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  getUserTasks(String taskID) {
      return FirebaseFirestore.instance.collection('users').doc(uid).collection(taskID); // turn this into a map of taskID to task objects?
  }

  Future<void> setUserTasks(String taskID, Task t) async {
      return await users.doc(uid).collection('tasks').doc(taskID).set(t.toMap());
  }

}
