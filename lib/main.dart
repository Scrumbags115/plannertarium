import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/login.dart';
import 'package:planner/view/loginView.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  print("IN MAIN");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // needs firebase_options.dart from flutterfire configure
  );

  //Uncomment below line and comment out above line to see weekView + dayView UI
  runApp(const GetMaterialApp(home: LoginView()));
  // runApp(const MyApp());
  logout();
}
