import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/login.dart';
import 'package:planner/view/taskView.dart';
import 'package:slider_button/slider_button.dart';


class loginView extends StatefulWidget {
  const loginView({super.key});
  @override
  _loginViewState createState() => _loginViewState();
}

class _loginViewState extends State<loginView> {
  bool isLogin = false; // Assuming this is a state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', 
              width:300,
              height: 300,
            ),
            const SizedBox(height: 300),
            // Replace ElevatedButton with SliderButton
            Center(
              child: SliderButton(
                width: 200,
                height: 60,
                action:() async {
                  User? u = await runAuthFlow();
                DatabaseService db = DatabaseService();
                db.initUID(u!.uid);
                setState(() {
                  isLogin = true;
                });
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const taskView(),
                  ),
                );
                },
                label: Text(
                  "Slide to login!",
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
