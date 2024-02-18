import 'package:attendance/components/styles.dart';
import 'package:attendance/models/students_model.dart';
import 'package:attendance/models/users_model.dart';
import 'package:attendance/screens/attendance_screen.dart';
import 'package:attendance/utils/firebase_utils.dart';
import 'package:flutter/material.dart';

class AdminViewUserScreen extends StatefulWidget {
  const AdminViewUserScreen({super.key});

  static String id = 'AdminViewUserScreen';

  @override
  State<AdminViewUserScreen> createState() => _AdminViewUserScreenState();
}

class _AdminViewUserScreenState extends State<AdminViewUserScreen> {
  List<Map<String, dynamic>> _parents = [];

  @override
  void initState() {
    super.initState();
    _fetchParents();
  }

  Future<void> _fetchParents() async {
    final fetchedParents = await FirebaseUtils.fetchParents();
    setState(() {
      _parents = fetchedParents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Parents'),
        backgroundColor: kAppBarBackgroundColor,
      ),
      backgroundColor: kBackgroundColor,
      body: ListView.builder(
        itemCount: _parents.length,
        itemBuilder: (context, index) {
          final parent = _parents[index];
          final UserModel parentData = parent['data'];
          return Card(
            child: ExpansionTile(
              title: Text(parentData.parentName),
              subtitle: Text(parentData.email),
              children: [
                FutureBuilder<List<MapEntry<String, StudentModel>>>(
                  future:
                      FirebaseUtils.fetchStudentsbyID(parentData.studentIDs),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Column(
                        children: snapshot.data!.map((studentWithId) {
                          return ListTile(
                            tileColor: kListTileColor,
                            title: Text(studentWithId.value.studentName),
                            subtitle: Text(
                                'Remaining Classes: ${studentWithId.value.remainingClasses}'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendanceScreen(
                                    studentId: studentWithId.key,
                                    parentId: parent['id']),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return const ListTile(
                        title: Text('No students found for this parent'),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
