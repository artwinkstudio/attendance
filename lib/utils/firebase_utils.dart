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
}
