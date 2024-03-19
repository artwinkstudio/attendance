import 'package:attendance/components/styles.dart';
import 'package:attendance/models/users_model.dart';
import 'package:attendance/models/students_model.dart'; 
import 'package:attendance/screens/attendance_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance/utils/firebase_utils.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});
  static const String id = '/SelectionScreen';

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Students'),
        backgroundColor: kAppBarBackgroundColor,
      ),
      backgroundColor: kBackgroundColor,
      body: SafeArea(child: _buildUserAndStudentsList()),
    );
  }

  Widget _buildUserAndStudentsList() {
    return Column(
      children: [
        _buildCurrentUserHeader(),
        _buildStudentsList(),
      ],
    );
  }

  Widget _buildCurrentUserHeader() {
    return FutureBuilder<UserModel?>(
      future: FirebaseUtils.fetchParentByID(currentUserUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Loading...", style: TextStyle(fontSize: 20)),
          );
        } else if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Hi ${snapshot.data!.parentName}, please select:',
              style: kSmallTextStyle,
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Error or no user found"),
          );
        }
      },
    );
  }

  Widget _buildStudentsList() {
    return Expanded(
      child: FutureBuilder<List<MapEntry<String, StudentModel>>>(
        future: FirebaseUtils.fetchParentByID(currentUserUid)
            .then((user) => FirebaseUtils.fetchStudentsbyID(user!.studentIDs)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var studentWithId = snapshot.data![index];
                return _buildStudentListItem(
                    studentWithId.key, studentWithId.value);
              },
            );
          } else {
            return const Center(
                child: Text("No students found or error occurred"));
          }
        },
      ),
    );
  }

  Widget _buildStudentListItem(String studentDocId, StudentModel student) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        color: kListTileColor,
        child: ListTile(
          title: Text(student.studentName),
          subtitle: Text('Remaining Classes: ${student.remainingClasses}'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendanceScreen(
                  parentId: currentUserUid, studentId: studentDocId),
            ),
          ),
        ),
      ),
    );
  }
}
