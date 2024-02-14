import 'package:attendance/components/assets.dart';
import 'package:attendance/components/styles.dart';
import 'package:attendance/screens/admin_screen.dart';
import 'package:attendance/screens/selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String id = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    print("loginUser called"); // Verify that loginUser is called

    FocusScope.of(context).unfocus(); // Dismiss the keyboard
    final emailAddress = _emailController.text.trim();
    final password = _passwordController.text;

    if (emailAddress.isEmpty || password.isEmpty) {
      print('emailAddress or password is empty');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      if (mounted) {
        print("Attempting to navigate to SelectionScreen");

        Navigator.pushNamed(context, SelectionScreen.id);
      } else {
        print("Is not mounted");
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      String errorMessage =
          'No user found for that email or wrong password provided for that user.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 130),
                logoImage,
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: emailInputDecoration,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: passwordInputDecoration,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: loginUser,
                  style: kbuttonStyle,
                  child: const Text('Login', style: kbuttonTextStyle),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AdminScreen.id);
                  },
                  style: kbuttonStyleAbmin,
                  child: const Text('Admin', style: kbuttonTextStyle),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
