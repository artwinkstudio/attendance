import 'package:attendance/components/assets.dart';
import 'package:attendance/components/styles.dart';
import 'package:attendance/models/studnets_model.dart';
import 'package:attendance/models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  static String id = '/AdminScreen';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final GlobalKey<FormState> _formKeyUser = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStudent = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAttendance = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _parentName = '';
  String _studentName = '';
  int _remainingClasses = 0;
  String? _selectedParentId;
  String? _selectedStudentId;
  List<Map<String, dynamic>> _parents = [];
  List<Map<String, dynamic>> _students = [];
  DateTime _selectedDate = DateTime.now();
  bool _isPresent = true;
  String? _selectedClassName;

  @override
  void initState() {
    super.initState();
    _fetchParents();
    _fetchStudents();
  }

  Future<void> _fetchParents() async {
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

      setState(() {
        _parents = fetchedParents;
      });
    } catch (e) {
      print("Error fetching parents: $e");
    }
  }

  Future<void> _fetchStudents() async {
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

      setState(() {
        _students = fetchedStudents;
      });
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  Future<void> _createUserWithEmailAndPassword() async {
    if (_formKeyUser.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _email,
          'parentName': _parentName,
          'studentIDs': [],
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("User created successfully")));

        // Clear the form fields (if necessary) and reset the form
        _email = '';
        _password = '';
        _parentName = '';
        // Reset the form state if you're clearing fields
        _formKeyUser.currentState?.reset();

        // Refetch the parents to update the dropdown
        await _fetchParents();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error creating user: $e")));
      }
    }
  }

  Future<void> _createStudent() async {
    if (_formKeyStudent.currentState!.validate()) {
      try {
        // Create the student in Firestore
        DocumentReference studentRef =
            await FirebaseFirestore.instance.collection('students').add({
          'studentName': _studentName,
          'remainingClasses': _remainingClasses,
          'parentId': _selectedParentId,
        });

        // Get the newly created student's Firestore document ID
        String newStudentId = studentRef.id;

        // Add the new student's ID to the selected parent's 'studentIDs' array
        DocumentReference parentRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_selectedParentId);
        await parentRef.update({
          'studentIDs': FieldValue.arrayUnion([newStudentId]),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Student created and added to parent successfully")));

        // Optionally, clear the form fields and update UI as needed
        _studentName = '';
        _remainingClasses = 0;
        _selectedParentId = null; // Reset selected parent ID if needed

        _formKeyStudent.currentState?.reset();

        // Refetch the parents to update the dropdown
        await _fetchStudents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error creating student: $e")));
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      // Update the _selectedDate with the picked time
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _addAttendance() async {
    if (_formKeyAttendance.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('attendance').add({
          'studentId': _selectedStudentId,
          'parentId': _selectedParentId,
          'attendanceDate': Timestamp.fromDate(_selectedDate),
          'attendance': _isPresent,
          'className': _selectedClassName,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Attendance recorded successfully")));

        // Reset the form and state after successful submission
        _formKeyAttendance.currentState?.reset();
        setState(() {
          // Reset your custom state variables to their initial values
          _selectedDate = DateTime.now(); // Reset to current date
          _isPresent = true; // Reset to default attendance value
          _selectedStudentId = null; // Clear the selected student
          _selectedParentId = null; // Clear the selected parent
          _selectedClassName = null; // Reset the selected class name
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error recording attendance: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
        backgroundColor: kAppBarBackgroundColor,
      ),
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form for creating a user
              Form(
                key: _formKeyUser, // Unique GlobalKey<FormState> for this form
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      onChanged: (value) => _email = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter an email' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onChanged: (value) => _password = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a password' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Parent Name'),
                      onChanged: (value) => _parentName = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a parent name' : null,
                    ),
                    ElevatedButton(
                      onPressed: _createUserWithEmailAndPassword,
                      child: Text('Create User'),
                    ),
                  ],
                ),
              ),
              adminDivider,

              // Form for creating a student
              Form(
                key:
                    _formKeyStudent, // Unique GlobalKey<FormState> for this form
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Student Name'),
                      onChanged: (value) => _studentName = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a student name' : null,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Remaining Classes'),
                      onChanged: (value) =>
                          _remainingClasses = int.tryParse(value) ?? 0,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter remaining classes'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedParentId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedParentId = newValue;
                        });
                      },
                      items: _parents.map((parent) {
                        return DropdownMenuItem<String>(
                          value: parent['id'],
                          child: Text(parent['data'].parentName),
                        );
                      }).toList(),
                      hint: Text('Select a Parent'),
                    ),
                    ElevatedButton(
                      onPressed: _createStudent,
                      child: Text('Create Student'),
                    ),
                  ],
                ),
              ),
              adminDivider,
              Form(
                key: _formKeyAttendance,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedStudentId,
                      onChanged: (String? newValue) async {
                        setState(() {
                          _selectedStudentId = newValue;
                        });
                        if (newValue != null) {
                          final DocumentSnapshot studentDoc =
                              await FirebaseFirestore.instance
                                  .collection('students')
                                  .doc(newValue)
                                  .get();
                          final studentData =
                              studentDoc.data() as Map<String, dynamic>;
                          final String? parentId = studentData['parentId'];

                          // Update the parent dropdown to reflect the selected student's parent
                          // But allow the admin to change it if needed
                          setState(() {
                            _selectedParentId = parentId;
                          });
                        }
                      },
                      items: _students.map((student) {
                        return DropdownMenuItem<String>(
                          value: student['id'],
                          child: Text(student['data'].studentName),
                        );
                      }).toList(),
                      decoration:
                          InputDecoration(labelText: 'Select a Student'),
                      validator: (value) =>
                          value == null ? 'Please select a student' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedParentId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedParentId = newValue;
                        });
                      },
                      items: _parents.map((parent) {
                        return DropdownMenuItem<String>(
                          value: parent['id'],
                          child: Text(parent['data'].parentName),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Select a Parent'),
                    ),
                    // Date Picker Button
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2025),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                              "Select date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _selectTime(context),
                          child: Text(
                              "Select Time: ${DateFormat('HH:mm').format(_selectedDate)}"),
                        ),
                      ],
                    ),

                    // Attendance Status Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Present'),
                      value: _isPresent,
                      onChanged: (bool value) {
                        setState(() {
                          _isPresent = value;
                        });
                      },
                    ),
                    // Class Name TextField
                    DropdownButtonFormField<String>(
                      value: _selectedClassName,
                      decoration: InputDecoration(labelText: 'Class Name'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClassName = newValue;
                        });
                      },
                      items: <String>[
                        'Traditional Art Class',
                        'Digital Art Class'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a class name' : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Call the method to add attendance when the button is pressed
                          if (_formKeyAttendance.currentState!.validate()) {
                            _addAttendance();
                          }
                        },
                        child: Text('Record Attendance'),
                      ),
                    ),
                  ],
                ),
              ),
              adminDivider,
            ],
          ),
        ),
      ),
    );
  }
}
