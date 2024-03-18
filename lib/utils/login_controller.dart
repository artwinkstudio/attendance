import 'package:attendance/utils/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController {
  final FirebaseAuth _firebaseAuth;
  final SnackbarUtil _snackbarUtil;

  LoginController(this._firebaseAuth, this._snackbarUtil);

  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
    required Function onAdminLogin,
    required Function onUserLogin,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _snackbarUtil.showSnackbar(context, 'Email or password cannot be empty.');
      return;
    }

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (email == 'artwinkstudio@gmail.com') {
        onAdminLogin();
      } else {
        onUserLogin();
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e, context);
    }
  }

  void _handleFirebaseAuthException(
      FirebaseAuthException e, BuildContext context) {
    String errorMessage = 'An error occurred. Please try again.';
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password provided for that user.';
        break;
    }
    _snackbarUtil.showSnackbar(context, errorMessage);
  }
}
