import 'package:attendance/firebase_options.dart';
import 'package:attendance/screens/admin_screen.dart';
import 'package:attendance/screens/attendance_screen.dart';
import 'package:attendance/screens/login_screen.dart';
import 'package:attendance/screens/selection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Attendance());
}

class Attendance extends StatelessWidget {
  const Attendance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        SelectionScreen.id : (context) => const SelectionScreen(),
        AttendanceScreen.id: (context) => const AttendanceScreen(),
        AdminScreen.id:(context) =>  const AdminScreen(),
      },
    );
  }
}