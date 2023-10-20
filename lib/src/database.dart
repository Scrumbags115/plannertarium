import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:planner/firebase_options.dart'
import 'package:planner/main.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('-- WidgetsFlutterBinding.ensureInitialized');

  await Firebase.initializeApp();
  print('-- main: Firebase.initializeApp');

  var db = FirebaseFirestore.instance;

  print("hello");

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyBwR4cKdPaa5c7p0fMLcAgu-VL8w3L3IUs',
        appId: '1:86325497409:android:85586ccfa7c01ea29cc0c0',
        messagingSenderId: '86325497409',
        projectId: 'plannertarium-d1696'),
  );

  runApp(const plannerApp());
}