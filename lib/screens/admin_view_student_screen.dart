import 'package:attendance/components/styles.dart';
import 'package:flutter/material.dart';
import 'package:attendance/utils/firebase_utils.dart';
import 'attendance_screen.dart'; // Import your AttendanceScreen here

class AdminViewStudentScreen extends StatefulWidget {
  const AdminViewStudentScreen({super.key});

  static String id = 'AdminViewStudentScreen';

  @override
  State<AdminViewStudentScreen> createState() => _AdminViewStudentScreenState();
}

class _AdminViewStudentScreenState extends State<AdminViewStudentScreen> {
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final fetchedStudents = await FirebaseUtils.fetchStudents();
    setState(() {
      _students = fetchedStudents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarBackgroundColor,
        title: const Text('Students List'),
      ),
      backgroundColor: kBackgroundColor,
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return ListTile(
            tileColor: kListTileColor,
            title: Text(student['data'].studentName),
            subtitle:
                Text('Remaining Classes: ${student['data'].remainingClasses}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(
                      studentId: student['id'],
                      parentId: student['data'].parentId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
