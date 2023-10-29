import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyBwR4cKdPaa5c7p0fMLcAgu-VL8w3L3IUs',
            appId: '1:86325497409:android:85586ccfa7c01ea29cc0c0',
            messagingSenderId: '86325497409',
            projectId: 'plannertarium-d1696'),
    );
     runApp(const plannerApp());
}

class plannerApp extends StatefulWidget{
    const plannerApp({Key? key}): super(key: key);

    @override
    State<plannerApp> createState() => _plannerAppState();
}

class _plannerAppState extends State<plannerApp>{
    final FirebaseAuth auth=FirebaseAuth.instance;
    final FirebaseFirestore firestore=FirebaseFirestore.instance;
    final User? user=FirebaseAuth.instance.currentUser;
    bool login=false;

    @override

    void initState(){
        super.initState();
        FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        auth.authStateChanges().listen((user) {
            setState(() {
              login=user!=null;
            });
        });
    }

    @override
    Widget build(BuildContext context){
        return GetMaterialApp(
            // home: login ? eventView() : loginView(),
        );
    }
}

