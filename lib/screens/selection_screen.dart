import 'package:attendance/components/styles.dart';
import 'package:attendance/models/users_model.dart';
import 'package:attendance/models/studnets_model.dart';
import 'package:attendance/screens/attendance_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  static String id = '/SelectionScreen';

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  late Future<UserModel?> currentUserFuture;

  Future<UserModel?> fetchCurrentUser(String currentUserUid) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      if (userDoc.exists) {
        UserModel currentUser =
            UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        return currentUser;
      } else {
        print("No user found with uid: $currentUserUid");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<List<MapEntry<String, StudentModel>>> fetchStudents(
      List<String> studentIds) async {
    List<MapEntry<String, StudentModel>> studentsWithIds = [];
    for (String id in studentIds) {
      var studentDoc =
          await FirebaseFirestore.instance.collection('students').doc(id).get();
      if (studentDoc.exists) {
        studentsWithIds.add(
          MapEntry(id,
              StudentModel.fromJson(studentDoc.data() as Map<String, dynamic>)),
        );
      }
    }
    return studentsWithIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Students'),
        backgroundColor: kAppBarBackgroundColor, // Example color
      ),
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder<UserModel?>(
              future: fetchCurrentUser(currentUserUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child:  Text("Loading...", style: TextStyle(fontSize: 20)),
                  );
                } else if (snapshot.hasData) {
                  UserModel? user = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'Hi ${user!.parentName}, please select:',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Error or no user found"),
                  );
                }
              },
            ),
            Expanded(
              child: FutureBuilder<List<MapEntry<String, StudentModel>>>(
                future: fetchCurrentUser(currentUserUid)
                    .then((user) => fetchStudents(user!.studentIDs)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    List<MapEntry<String, StudentModel>> studentsWithIds =
                        snapshot.data!;
                    return ListView.builder(
                      itemCount: studentsWithIds.length,
                      itemBuilder: (context, index) {
                        var studentWithId = studentsWithIds[index];
                        String studentDocId = studentWithId.key;
                        StudentModel student = studentWithId.value;

                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Card(
                            color: kListTileColor,
                            child: ListTile(
                              title: Text(student.studentName),
                              subtitle: Text(
                                  'Remaining Classes: ${student.remainingClasses}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceScreen(
                                      parentId: currentUserUid,
                                      studentId: studentDocId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text("No students found or error occurred"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
