// attendance_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  String parentId;
  String studentId;
  bool attendance;
  DateTime attendanceDate;
  String className;

  AttendanceModel({
    required this.parentId,
    required this.studentId,
    required this.attendance,
    required this.attendanceDate,
    required this.className,
  });

  Map<String, dynamic> toJson() => {
        'parentId': parentId,
        'studentId': studentId,
        'attendance': attendance,
        'attendanceDate': attendanceDate,
        'className': className,
      };

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        parentId: json['parentId'],
        studentId: json['studentId'],
        attendance: json['attendance'],
        attendanceDate: (json['attendanceDate'] as Timestamp).toDate(),
        className: json['className'],
      );
}
