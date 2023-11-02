import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class SnackBarDemo extends StatelessWidget {
  const SnackBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnackBar Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SnackBar Demo'),
        ),
        body: const SnackBarPage(),
      ),
    );
  }
}



class SnackBarPage extends StatelessWidget {
  const SnackBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          final snackBar = SnackBar(
            content: const Text('Yay! A SnackBar!'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the ScaffoldMessenger in the widget tree
          // and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: const Text('Show SnackBar'),
      ),
    );
  }
}

Future<User> triggerAuthFlowWeb() async {
  UserCredential u = await signInWithGoogleWeb();
  User? user = u.user;
  if (user == null) {
// sign in did not work or cancelled
    throw Exception("Something in the login procedure failed!");
  }
  return user;
}

Future<User> triggerAuthFlowAndroid() async {
  UserCredential u = await signInWithGoogleWeb();
  User? user = u.user;
  if (user == null) {
// sign in did not work or cancelled
    throw Exception("Something in the login procedure failed!");
  }
  return user;
}

/// Sign in with Google SSO, taken from documentation
Future<UserCredential> signInWithGoogleWeb() async {
// Create a new provider
  GoogleAuthProvider googleProvider = GoogleAuthProvider();

// googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
  googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

// Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithPopup(googleProvider);

// Or use signInWithRedirect
// return FirebaseAuth.instance.signInWithRedirect(googleProvider);
}

Future<UserCredential> signInWithGoogleMobile() async {
// Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

// Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

// Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

// Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future<User> triggerAuthFlow() async {
  if (kIsWeb) {
    return triggerAuthFlowWeb();
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return triggerAuthFlowAndroid();
    case TargetPlatform.iOS:
      throw UnsupportedError("iOS is not supported!");
    case TargetPlatform.macOS:
      throw UnsupportedError("macOS is not supported!");
    case TargetPlatform.windows:
      throw UnsupportedError("windows is not supported!");
    case TargetPlatform.linux:
      throw UnsupportedError("linux is not supported!");
    default:
      throw UnsupportedError('Unknown platform is not supported!');
  }
}

Future<String> runAuthFlow() async {
  try {
    User u = await triggerAuthFlow();
    return u.uid;
  } on FirebaseAuthException catch (e) {
    print("Error!$e");

    return "";
  }
}