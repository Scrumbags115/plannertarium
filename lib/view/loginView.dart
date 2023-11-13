import 'dart:developer';
import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planner/common/login.dart';
import 'package:planner/models/task.dart';
import 'package:planner/tests/task_tests.dart';
import 'package:planner/view/taskView.dart';
import 'dart:async';
import 'package:planner/view/weekView.dart';

class loginView extends StatefulWidget {
  const loginView({Key? key}) : super(key: key);
  @override
  _loginViewState createState() => _loginViewState();
}

class _loginViewState extends State<loginView> {
  bool isLogin = false; // Set this based on your login logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Plannertarium',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                User? u = await runAuthFlow();
                DatabaseService db = DatabaseService(uid: u!.uid);
                db.initUID(u!.uid);
                setState(() {
                  isLogin = true;
                });
                // Navigate to the next page after authentication
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => taskView(),
                  ),
                );
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
