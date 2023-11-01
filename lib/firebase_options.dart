// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZGLE7nkKMlGA5zuxHM0kSACM066Mj8Ao',
    appId: '1:86325497409:web:98f01f217afeb0779cc0c0',
    messagingSenderId: '86325497409',
    projectId: 'plannertarium-d1696',
    authDomain: 'plannertarium-d1696.firebaseapp.com',
    storageBucket: 'plannertarium-d1696.appspot.com',
    measurementId: 'G-HM91TY6988',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBwR4cKdPaa5c7p0fMLcAgu-VL8w3L3IUs',
    appId: '1:86325497409:android:a2cc7cf176c84ac19cc0c0',
    messagingSenderId: '86325497409',
    projectId: 'plannertarium-d1696',
    storageBucket: 'plannertarium-d1696.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCyEcuk8ws6jzJCLyncfad8a96Hx81JuuU',
    appId: '1:86325497409:ios:8c7e2e61e837689f9cc0c0',
    messagingSenderId: '86325497409',
    projectId: 'plannertarium-d1696',
    storageBucket: 'plannertarium-d1696.appspot.com',
    androidClientId: '86325497409-f2410jcidfas1b8rl4gtonlckkc2ej6v.apps.googleusercontent.com',
    iosClientId: '86325497409-ql5gu7ulc1gsvl2vvvssvgqvoj25men0.apps.googleusercontent.com',
    iosBundleId: 'com.example.planner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCyEcuk8ws6jzJCLyncfad8a96Hx81JuuU',
    appId: '1:86325497409:ios:a92f520aa01377069cc0c0',
    messagingSenderId: '86325497409',
    projectId: 'plannertarium-d1696',
    storageBucket: 'plannertarium-d1696.appspot.com',
    androidClientId: '86325497409-f2410jcidfas1b8rl4gtonlckkc2ej6v.apps.googleusercontent.com',
    iosClientId: '86325497409-tn3uvct9a9p9rmr2ek95g1vieojou7l0.apps.googleusercontent.com',
    iosBundleId: 'com.example.planner.RunnerTests',
  );
}
