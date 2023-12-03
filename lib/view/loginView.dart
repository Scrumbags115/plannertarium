import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/login.dart';
import 'package:planner/view/dailyTaskView.dart';
import 'package:slider_button/slider_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  bool isLogin = false; // Assuming this is a state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Plannertarium',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 50),
              Image.asset(
                'assets/logo.png',
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 300),
              // Replace ElevatedButton with SliderButton
              Center(
                child: SliderButton(
                  width: 200,
                  height: 60,
                  action: () {
                    runAuthFlow().then((u) {
                      DatabaseService db = DatabaseService();
                      db.initUID(u!.uid);
                      db.initUsername(u.displayName!);
                      db.initEmail(u.email!);
                      db.initPFP(u.photoURL!);
                      setState(() {
                        isLogin = true;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskView(),
                        ),
                      );
                    });
                  },
                  label: const Text(
                    "Slide to login!",
                    style: TextStyle(
                      color: Color(0xff4a4a4a),
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
