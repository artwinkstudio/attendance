import 'package:attendance/firebase_options.dart';
import 'package:attendance/screens/admin/admin_screen.dart';
import 'package:attendance/screens/admin/admin_view_attendance_screen.dart';
import 'package:attendance/screens/admin/admin_view_student_screen.dart';
import 'package:attendance/screens/admin/admin_view_user_screen.dart';
import 'package:attendance/screens/attendance_screen.dart';
import 'package:attendance/screens/login_screen.dart';
import 'package:attendance/screens/selection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
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
      title: 'ArtWinkStudio - Attendance',
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        SelectionScreen.id: (context) => const SelectionScreen(),
        AdminScreen.id: (context) => const AdminScreen(),
        AdminViewUserScreen.id: (context) => const AdminViewUserScreen(),
        AdminViewStudentScreen.id: (context) => const AdminViewStudentScreen(),
        AdminViewAttendanceScreen.id: (context) =>
            const AdminViewAttendanceScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AttendanceScreen.id) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
              builder: (context) => AttendanceScreen(
                    parentId: args['parentId'],
                    studentId: args['studentId'],
                  ));
        } else {
          return null;
        }
      },
    );
  }
}
