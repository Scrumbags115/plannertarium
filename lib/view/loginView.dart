import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/login.dart';
import 'package:planner/view/taskView.dart';
import 'package:slider_button/slider_button.dart';

class SwitchListTileExample extends StatefulWidget {
  final Function callback;
  const SwitchListTileExample(this.callback, {super.key});

  @override
  State<SwitchListTileExample> createState() => _SwitchListTileExampleState();
}

class _SwitchListTileExampleState extends State<SwitchListTileExample> {
  bool _on = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Login:'),
      value: _on,
      onChanged: (bool value) {
        setState(() {
          _on = value;
        });
        widget.callback();
      },
      secondary: const Icon(Icons.login),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  LoginViewState createState() => LoginViewState();
}

bool isOnIOSorAndroid() {
  return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
}

Widget dynamicSlider(bool value, Function callback) {

  if (isOnIOSorAndroid()) {
    return SliderButton(
      width: 200,
      height: 60,
      action: () {
        callback();
      },
      label: const Text(
        "Slide to login!",
        style: TextStyle(
          color: Color(0xff4a4a4a),
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
      ),
    );
  } else {
    return Container(
      alignment: Alignment.center,
      child: SwitchListTileExample(callback),
    );
  }
}
class LoginViewState extends State<LoginView> {
  bool isLogin = false; // Assuming this is a state variable

  void loginAndSetup() {
    runAuthFlow().then((u) {
      DatabaseService db = DatabaseService();
      db.initUID(u!.uid);
      db.initUsername(u.displayName!);
      db.initEmail(u.email!);
      db.initPFP(u.photoURL!);
      setState(() {
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TaskView(),
        ),
      );
    });
  }
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
                child: dynamicSlider(isLogin, loginAndSetup),
              )
            ],
          ),
        ),
      ),
    );
  }
}
