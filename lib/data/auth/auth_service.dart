// lib/data/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use the constructor directly, not the `instance` getter
  final GoogleSignIn _googleSignIn = GoogleSignIn(); 

  // The initialize() method does not exist in 6.x.x, so it must be removed.
  // This also means you should remove the call to this method from your `main.dart`.
  //
  // Future<void> initialize() async {
  //   // REMOVE THIS METHOD
  // }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Use signIn() instead of authenticate() for version 6.x.x
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut(); 
    await _auth.signOut();
  }
}