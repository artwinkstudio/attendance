import 'package:attendance/components/assets.dart';
import 'package:attendance/components/styles.dart';
import 'package:attendance/screens/admin_view_user_screen.dart';
import 'package:attendance/utils/snackbar_utils.dart';
import 'package:attendance/utils/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  static String id = '/AdminScreen';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _parents = [];
  List<Map<String, dynamic>> _students = [];
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
  DateTime _selectedDate = DateTime.now();
  bool _isPresent = true;
  String? _selectedClassName;

  final _snackbarUtil = SnackbarUtil();

  @override
  void initState() {
    super.initState();
    _fetchParents();
    _fetchStudents();
  }

  Future<void> _fetchParents() async {
    final fetchedParents = await FirebaseUtils.fetchParents();
    setState(() {
      _parents = fetchedParents;
    });
  }

  Future<void> _fetchStudents() async {
    final fetchedStudents = await FirebaseUtils.fetchStudents();
    setState(() {
      _students = fetchedStudents;
    });
  }

  Future<void> _createUser() async {
    if (_formKeyUser.currentState!.validate()) {
      FirebaseUtils.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
        parentName: _parentName,
        onSuccess: () {
          if (mounted) {
            _snackbarUtil.showSnackbar(context, "User created successfully");
          }
          setState(() {
            _email = '';
            _password = '';
            _parentName = '';
          });
          _formKeyUser.currentState?.reset();
          _fetchParents();
        },
        onError: (String message) {
          if (mounted) {
            _snackbarUtil.showSnackbar(context, message);
          }
        },
      );
    }
  }

  Future<void> _createStudent() async {
    if (_formKeyStudent.currentState!.validate()) {
      FirebaseUtils.createStudent(
        studentName: _studentName,
        remainingClasses: _remainingClasses,
        parentId: _selectedParentId ?? "",
        onSuccess: () {
          if (mounted) {
            _snackbarUtil.showSnackbar(
                context, "Student created and added to parent successfully");
          }

          setState(() {
            _studentName = '';
            _remainingClasses = 0;
            _selectedParentId = null;
          });

          _formKeyStudent.currentState?.reset();

          _fetchStudents();
        },
        onError: (String message) {
          if (mounted) {
            _snackbarUtil.showSnackbar(context, message);
          }
        },
      );
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
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
      FirebaseUtils.addAttendance(
        studentId: _selectedStudentId ?? "",
        parentId: _selectedParentId ?? "",
        attendanceDate: _selectedDate,
        isPresent: _isPresent,
        className: _selectedClassName ?? "",
        onSuccess: () {
          if (mounted) {
            _snackbarUtil.showSnackbar(
                context, "Attendance recorded successfully");
          }

          setState(() {
            _selectedDate = DateTime.now();
            _isPresent = true;
            _selectedStudentId = null;
            _selectedParentId = null;
            _selectedClassName = null;
          });

          _formKeyAttendance.currentState?.reset();
        },
        onError: (String message) {
          if (mounted) {
            _snackbarUtil.showSnackbar(context, message);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, AdminViewScreen.id),
              icon: const Icon(Icons.list)),
        ],
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
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (value) => _email = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter an email' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onChanged: (value) => _password = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a password' : null,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Parent Name'),
                      onChanged: (value) => _parentName = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a parent name' : null,
                    ),
                    ElevatedButton(
                      onPressed: _createUser,
                      child: const Text('Create User'),
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
                      decoration:
                          const InputDecoration(labelText: 'Student Name'),
                      onChanged: (value) => _studentName = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a student name' : null,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Remaining Classes'),
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
                      hint: const Text('Select a Parent'),
                    ),
                    ElevatedButton(
                      onPressed: _createStudent,
                      child: const Text('Create Student'),
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
                          const InputDecoration(labelText: 'Select a Student'),
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
                      decoration:
                          const InputDecoration(labelText: 'Select a Parent'),
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
                        const SizedBox(width: 8),
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
                      title: const Text('Present'),
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
                      decoration:
                          const InputDecoration(labelText: 'Class Name'),
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
                        child: const Text('Record Attendance'),
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
