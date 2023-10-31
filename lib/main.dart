import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:planner/temp_frontend2.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'common/login.dart';

Task t = Task(name: "test", tags: {});
DatabaseService d = DatabaseService(uid: "test_user_1");

void main() async {
  print("IN MAIN");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCZGLE7nkKMlGA5zuxHM0kSACM066Mj8Ao",
        authDomain: "plannertarium-d1696.firebaseapp.com",
        projectId: "plannertarium-d1696",
        storageBucket: "plannertarium-d1696.appspot.com",
        messagingSenderId: "86325497409",
        appId: "1:86325497409:web:98f01f217afeb0779cc0c0",
        measurementId: "G-HM91TY6988"),
  );
  d.setUserTasks("1", t);
  runApp(MyApp());

  await signInWithGoogle();

  User? u = FirebaseAuth.instance.currentUser;
  print(u);
  print("weeee");
}
