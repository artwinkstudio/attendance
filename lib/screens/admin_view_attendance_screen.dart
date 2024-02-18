import 'package:attendance/models/students_model.dart';
import 'package:attendance/models/users_model.dart';
import 'package:attendance/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:attendance/components/styles.dart';
import 'package:attendance/utils/firebase_utils.dart';
import 'package:intl/intl.dart';
import 'package:attendance/models/attendance_model.dart';

class AdminViewAttendanceScreen extends StatefulWidget {
  const AdminViewAttendanceScreen({Key? key}) : super(key: key);

  static const String id = 'AdminViewAttendanceScreen';

  @override
  State<AdminViewAttendanceScreen> createState() =>
      _AdminViewAttendanceScreenState();
}

class _AdminViewAttendanceScreenState extends State<AdminViewAttendanceScreen> {
  late Future<List<Map<String, dynamic>>> _attendancesFuture;
  final _snackbarUtil = SnackbarUtil();

  @override
  void initState() {
    super.initState();
    _attendancesFuture = FirebaseUtils.fetchAttendances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarBackgroundColor,
        title: const Text('Attendance List'),
      ),
      backgroundColor: kBackgroundColor,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendancesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final attendances = snapshot.data!;
            attendances.sort((a, b) {
              final DateTime aDate = a['data'].attendanceDate;
              final DateTime bDate = b['data'].attendanceDate;
              return bDate.compareTo(aDate);
            });

            return ListView.separated(
                itemCount: attendances.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final attendance = attendances[index];
                  final String docId = attendance['id'];
                  final AttendanceModel attendanceData = attendance['data'];

                  return FutureBuilder<UserModel?>(
                    future:
                        FirebaseUtils.fetchParentByID(attendanceData.parentId),
                    builder: (context, parentSnapshot) {
                      if (parentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text("Loading..."),
                        );
                      }

                      final parentName =
                          parentSnapshot.data?.parentName ?? 'No Parent Found';

                      return ListTile(
                        title: Text(attendanceData.className),
                        subtitle: Text(
                            "$parentName\n${DateFormat('yyyy-MM-dd h:mm a').format(attendanceData.attendanceDate)}"),
                        leading: CircleAvatar(
                          child:
                              _buildStudentListTile([attendanceData.studentId]),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteAttendance(docId, attendanceData.studentId),
                        ),
                      );
                    },
                  );
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildStudentListTile(List<String> studentIds) {
    return FutureBuilder<List<MapEntry<String, StudentModel>>>(
      future: FirebaseUtils.fetchStudentsbyID(studentIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final studentName = snapshot.data!.first.value.studentName;
          return Text(studentName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10));
        } else {
          return const Text('No student found');
        }
      },
    );
  }

  // Widget _buildParentDetails(String parentId) {
  //   return FutureBuilder<UserModel?>(
  //     future: FirebaseUtils.fetchParentByID(parentId),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const SizedBox(
  //           width: 24,
  //           height: 24,
  //           child: CircularProgressIndicator(),
  //         );
  //       } else if (snapshot.hasData) {
  //         final parent = snapshot.data!;
  //         return Text(parent.parentName, // Displaying parent's name
  //             overflow: TextOverflow.ellipsis,
  //             style: const TextStyle(fontSize: 10));
  //       } else {
  //         return const Text('No parent found');
  //       }
  //     },
  //   );
  // }

  void _deleteAttendance(String docId, String studentID) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text(
              "Are you sure you want to delete this attendance record?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                FirebaseUtils.deleteAttendance(docId).then((_) {
                  if (mounted) {
                    FirebaseUtils.incrementRemainingClasses(studentId: studentID);

                    _snackbarUtil.showSnackbar(
                        context, 'Attendance deleted successfully');
                  }

                  setState(() {
                    _attendancesFuture = FirebaseUtils.fetchAttendances();
                  });
                }).catchError((error) {
                  if (mounted) {
                    _snackbarUtil.showSnackbar(
                        context, 'Error deleting attendance: $error');
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
