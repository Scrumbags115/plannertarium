import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planner/view/loginView.dart';
import 'package:get/get.dart';
// import 'package:planner/temp_frontend2.dart';
import 'firebase_options.dart';


void main() async {
  print("IN MAIN");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // needs firebase_options.dart from flutterfire configure
  );

  //Uncomment below line and comment out above line to see weekView + dayView UI
  //runApp(GetMaterialApp(home: eventView()));
  //d.setUserTasks("1", t);
  //runApp(const MyApp());

  // test_tasks();
  // //Uncomment below line and comment out above line to see weekView + dayView UI
  runApp(const GetMaterialApp(home: loginView()));
  // User? u = await runAuthFlow();
  // DatabaseService d = DatabaseService(uid: u!.uid);
  // print(u.displayName);
  // print(u.uid);
  // print("wee");

  // Uncomment below line and comment out above line to see weekView + dayView UI
  // test_tasks();
  //Uncomment below line and comment out above line to see weekView + dayView UI

  //runApp(GetMaterialApp(home: weekView()));
  // d.setUserTask(t);
  // runApp(const MyApp());
}
