import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _currentUser;

  User? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.uid;
  bool get isAuthenticated => (_currentUser != null);

  AuthService() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      print("AuthService: User state changed. Current user: ${_currentUser
          ?.uid}");
      notifyListeners();
    });
  }

  // Sign in with native email/password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Error user-not-found: No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Error wrong-password: Wrong password provided for that user.');
      }
      // rethrow for UI
      rethrow;
    }
  }

  // Sign up with native email/password
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Error weak-password: Password provided is too weak (less than 6 characters).');
      } else if (e.code == 'email-already-in-use') {
        print('Error email-already-in-use: Account already exists for that email.');
      }
      // rethrow for UI
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

}