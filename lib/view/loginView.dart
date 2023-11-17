import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/login.dart';
import 'package:planner/view/taskView.dart';

class loginView extends StatefulWidget {
  const loginView({super.key});
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
            const Text(
              'Plannertarium',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                User? u = await runAuthFlow();
                DatabaseService db = DatabaseService();
                db.initUID(u!.uid);
                setState(() {
                  isLogin = true;
                });
                // Navigate to the next page after authentication
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const taskView(),
                  ),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
