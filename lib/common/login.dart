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
