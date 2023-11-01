import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';
import 'package:planner/temp_frontend.dart';
import 'package:planner/view/weekView.dart';
import 'package:get/get.dart';
import 'package:planner/temp_frontend2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'common/login.dart';
import 'firebase_options.dart';

Task t = Task(name: "test", tags: {});
DatabaseService d = DatabaseService(uid: "test_user_1");

void main() async {
  print("IN MAIN");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyBwR4cKdPaa5c7p0fMLcAgu-VL8w3L3IUs',
        appId: '1:86325497409:android:85586ccfa7c01ea29cc0c0',
        messagingSenderId: '86325497409',
        projectId: 'plannertarium-d1696'),
  );
  d.setUserTasks("1", t);
  runApp(const MyApp());
  //Uncomment below line and comment out above line to see weekView + dayView UI
  //runApp(GetMaterialApp(home: weekView()));
    options: DefaultFirebaseOptions.currentPlatform,
  );
  d.setUserTasks("1", t);
  runApp(const MyApp());
}
