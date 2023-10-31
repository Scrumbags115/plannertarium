import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// final FirebaseAuth auth=FirebaseAuth.instance;
// final FirebaseFirestore firestore=FirebaseFirestore.instance;
// final User? user=FirebaseAuth.instance.currentUser;
// bool login=false;
//
// @override
//
// void initState(){
//   super.initState();
//   FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
//   auth.authStateChanges().listen((user) {
//     setState(() {
//       login=user!=null;
//     });
//   });
// }

/// Sign in with Google SSO, taken from documentation
// Future<UserCredential> signInWithGoogle() async {
// // GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
// //
// // GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
// //
// // AuthCredential credential = GoogleAuthProvider.credential(
// //   accessToken: googleAuth?.accessToken,
// //   idToken: googleAuth?.idToken,
// // );
// //
// // UserCredential userCreds = await FirebaseAuth.instance.signInWithCredential(credential);
// // Create a new provider
// GoogleAuthProvider googleProvider = GoogleAuthProvider();

// // googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
// googleProvider.setCustomParameters({
//   'login_hint': 'user@example.com'
// });

// // Once signed in, return the UserCredential
// return await FirebaseAuth.instance.signInWithPopup(googleProvider);

// // Or use signInWithRedirect
// // return FirebaseAuth.instance.signInWithRedirect(googleProvider);
// }

Future<UserCredential> signInWithGoogle() async {
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
