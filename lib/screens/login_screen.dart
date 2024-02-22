import 'package:attendance/components/assets.dart';
import 'package:attendance/components/styles.dart';
import 'package:attendance/screens/admin_screen.dart';
import 'package:attendance/screens/selection_screen.dart';
import 'package:attendance/utils/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _snackbarUtil = SnackbarUtil();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final emailAddress = _emailController.text.trim();
    final password = _passwordController.text;

    if (emailAddress.isEmpty || password.isEmpty) {
      _snackbarUtil.showSnackbar(context, 'Email or password cannot be empty.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      if (!mounted) return;
      if (emailAddress == 'artwinkstudio@gmail.com') {
        Navigator.pushReplacementNamed(context, AdminScreen.id);
      } else {
        Navigator.pushReplacementNamed(context, SelectionScreen.id);
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
    }
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.height) / 5,
            ),
            const SizedBox(height: 20),
            logoImage,
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email', false),
            const SizedBox(height: 20),
            _buildTextField(_passwordController, 'Password', true),
            const SizedBox(height: 20),
            _buildLoginButton(),
            const SizedBox(height: 20),
            SizedBox(
              height: (MediaQuery.of(context).size.height) / 5,
            ),
          ],
        ),
      ),
    );
  }

  TextField _buildTextField(
      TextEditingController controller, String label, bool obscureText) {
    return TextField(
      controller: controller,
      keyboardType:
          obscureText ? TextInputType.text : TextInputType.emailAddress,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: _loginUser,
      style: kbuttonStyle,
      child: const Text('Login', style: kbuttonTextStyle),
    );
  }

//   Widget _buildAdminButton() {
//     return TextButton(
//       onPressed: () => Navigator.pushNamed(context, AdminScreen.id),
//       style: kbuttonStyleAbmin,
//       child: const Text('Admin', style: kbuttonTextStyle),
//     );
//   }
}
