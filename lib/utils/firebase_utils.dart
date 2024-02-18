import 'package:attendance/models/attendance_model.dart';
import 'package:attendance/models/students_model.dart';
import 'package:attendance/models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUtils {
  static Future<List<Map<String, dynamic>>> fetchParents() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final List<Map<String, dynamic>> fetchedParents =
          querySnapshot.docs.map((doc) {
        return {
          'data': UserModel.fromJson(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        };
      }).toList();

      return fetchedParents;
    } catch (e) {
      print("Error fetching parents: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchStudents() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('students').get();
      final List<Map<String, dynamic>> fetchedStudents =
          querySnapshot.docs.map((doc) {
        return {
          'data': StudentModel.fromJson(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        };
      }).toList();

      return fetchedStudents;
    } catch (e) {
      print("Error fetching student: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAttendances() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('attendance').get();
      final List<Map<String, dynamic>> fetchedAttendances =
          querySnapshot.docs.map((doc) {
        return {
          'data': AttendanceModel.fromJson(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        };
      }).toList();

      return fetchedAttendances;
    } catch (e) {
      print("Error fetching attendance: $e");
      return [];
    }
  }

  static Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String parentName,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    if (email.isEmpty || password.isEmpty || parentName.isEmpty) {
      onError("Please fill in all fields");
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'parentName': parentName,
        'studentIDs': [],
      });

      onSuccess();
    } catch (e) {
      onError("Error creating user: $e");
    }
  }

  static Future<void> createStudent({
    required String studentName,
    required int remainingClasses,
    required String parentId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    if (studentName.isEmpty || parentId.isEmpty) {
      onError("Student name and parent must be provided");
      return;
    }

    try {
      DocumentReference studentRef =
          await FirebaseFirestore.instance.collection('students').add({
        'studentName': studentName,
        'remainingClasses': remainingClasses,
        'parentId': parentId,
      });

      String newStudentId = studentRef.id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .update({
        'studentIDs': FieldValue.arrayUnion([newStudentId]),
      });

      onSuccess();
    } catch (e) {
      onError("Error creating student: $e");
    }
  }

  static Future<void> addAttendance({
    required String studentId,
    required String parentId,
    required DateTime attendanceDate,
    required bool isPresent,
    required String className,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('attendance').add({
        'studentId': studentId,
        'parentId': parentId,
        'attendanceDate': Timestamp.fromDate(attendanceDate),
        'attendance': isPresent,
        'className': className,
      });

      onSuccess();
    } catch (e) {
      onError("Error recording attendance: $e");
    }
  }

  static Future<List<MapEntry<String, StudentModel>>> fetchStudentsbyID(
      List<String> studentIds) async {
    List<MapEntry<String, StudentModel>> studentsWithIds = [];
    for (String id in studentIds) {
      var studentDoc =
          await FirebaseFirestore.instance.collection('students').doc(id).get();
      if (studentDoc.exists) {
        studentsWithIds.add(MapEntry(id,
            StudentModel.fromJson(studentDoc.data() as Map<String, dynamic>)));
      }
    }
    return studentsWithIds;
  }

  static Future<void> deleteAttendance(String docId) async {
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(docId)
        .delete();
  }

  static Future<UserModel?> fetchParentByID(String parentId) async {
    try {
      DocumentSnapshot parentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .get();

      if (parentDoc.exists) {
        UserModel parent = UserModel.fromJson(
            {...parentDoc.data() as Map<String, dynamic>, 'id': parentDoc});

        return parent;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching parent by ID: $e");
      return null;
    }
  }

  static Future<StudentModel?> fetchStudentByID(String studentId) async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        StudentModel student = StudentModel.fromJson({
          ...studentDoc.data() as Map<String, dynamic>,
          'id': studentDoc.id
        });

        return student;
      } else {
        print('students not exists');
        return null;
      }
    } catch (e) {
      print("Error fetching student by ID: $e");
      return null;
    }
  }

  static Future<void> incrementRemainingClasses({
    required String studentId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({'remainingClasses': FieldValue.increment(1)});
    } catch (e) {
      print("Error incrementing remaining classes: $e");
    }
  }
}
