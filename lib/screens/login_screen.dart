import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:attendance/components/assets.dart';
import 'package:attendance/components/styles.dart';
import 'package:attendance/screens/admin/admin_screen.dart';
import 'package:attendance/screens/selection_screen.dart';
import 'package:attendance/utils/snackbar_utils.dart';
import 'package:attendance/utils/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String id = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // FocusNodes for managing focus
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Login controller
  final LoginController _loginController =
      LoginController(FirebaseAuth.instance, SnackbarUtil());

  @override
  void initState() {
    super.initState();
    // Optionally request focus on the email field when the widget is built
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _emailFocusNode.requestFocus();
    // });
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: _buildLoginForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return AutofillGroup(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          logoImage,
          const SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email',
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            autofillHints: [AutofillHints.username, AutofillHints.email],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            obscureText: true,
            keyboardType: TextInputType.text,
            autofillHints: [AutofillHints.password],
          ),
          const SizedBox(height: 20),
          _buildLoginButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool obscureText,
    required TextInputType keyboardType,
    required List<String> autofillHints,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autofillHints: autofillHints,
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
