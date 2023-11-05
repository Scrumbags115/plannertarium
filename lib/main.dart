import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
// import 'package:planner/temp_frontend.dart';
import 'package:planner/view/weekView.dart';
import 'package:get/get.dart';
import 'package:planner/temp_frontend2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'common/login.dart';
import 'firebase_options.dart';

Task t = Task(name: "test", tags: {});

void main() async {
  print("IN MAIN");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // needs firebase_options.dart from flutterfire configure
  );

  User? u = await runAuthFlow();
  DatabaseService d = DatabaseService(uid: u!.uid);
  print(u.displayName);
  print(u.uid);
  // print("wee");

  //Uncomment below line and comment out above line to see weekView + dayView UI
  runApp(GetMaterialApp(home: weekView()));
  d.setUserTasks("4", t);
  // runApp(const MyApp());
}
