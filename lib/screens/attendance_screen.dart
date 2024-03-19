import 'package:attendance/components/styles.dart';
import 'package:attendance/models/attendance_model.dart';
import 'package:attendance/utils/firebase_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    required this.parentId,
    required this.studentId,
    super.key,
  });

  final String parentId;
  final String studentId;
  static const String id = '/AttendanceScreen';

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
        backgroundColor: kAppBarBackgroundColor,
      ),
      backgroundColor: kBackgroundColor,
      body: FutureBuilder<List<AttendanceModel>>(
        future: FirebaseUtils.fetchAttendanceRecords(widget.parentId, widget.studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text("Error fetching attendance records"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildAttendanceList(snapshot.data!);
          } else {
            return const Center(child: Text("No attendance records found"));
          }
        },
      ),
    );
  }

  Widget _buildAttendanceList(List<AttendanceModel> attendanceRecords) {
    // Sort the attendance records by date in descending order
    attendanceRecords
        .sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));

    return ListView.builder(
      itemCount: attendanceRecords.length,
      itemBuilder: (context, index) {
        AttendanceModel record = attendanceRecords[index];
        String formattedDate =
            DateFormat('yyyy-MM-dd h:mm a').format(record.attendanceDate);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: kListTileColor,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: kAppBarBackgroundColor,
                child: Text('${attendanceRecords.length - index}',
                    style: const TextStyle(color: Colors.black)),
              ),
              title: Text(record.className),
              subtitle: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(text: 'Date: $formattedDate - '),
                    TextSpan(
                      text: record.attendance ? 'Present' : 'Absence (Please make up within one month)',
                      style: TextStyle(
                          color: record.attendance ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
