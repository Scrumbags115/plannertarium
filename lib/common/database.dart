import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/models/event.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // users collection reference
  // todo: merge with task branch
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  getUserTasks(String eventID) {
    return FirebaseFirestore.instance.collection('users').doc(uid).collection("events").doc(eventID); // turn this into a map of taskID to task objects?
  }

  Future<void> setUserTasks(String taskID, Event e) async {
    return await users.doc(uid).collection("events").doc(taskID).set(e.toMap());
  }

}