import 'package:attendance/components/assets.dart';
import 'package:attendance/components/styles.dart';
import 'package:attendance/screens/admin/admin_screen.dart';
import 'package:attendance/screens/selection_screen.dart';
import 'package:attendance/utils/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance/utils/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _loginController =
      LoginController(FirebaseAuth.instance, SnackbarUtil());

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: 40.0,
          left: 40.0,
          right: 40.0,
          bottom: 40.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            logoImage,
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email', false),
            const SizedBox(height: 20),
            _buildTextField(_passwordController, 'Password', true),
            const SizedBox(height: 20),
            _buildLoginButton(),
            const SizedBox(height: 20),
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
          obscureText ? TextInputType.number : TextInputType.emailAddress,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        _loginController.loginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          context: context,
          onAdminLogin: () =>
              Navigator.pushReplacementNamed(context, AdminScreen.id),
          onUserLogin: () =>
              Navigator.pushReplacementNamed(context, SelectionScreen.id),
        );
      },
      style: kbuttonStyle,
      child: const Text('Login', style: kbuttonTextStyle),
    );
  }
}
