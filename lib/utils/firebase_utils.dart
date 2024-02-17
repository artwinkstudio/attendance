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
}
