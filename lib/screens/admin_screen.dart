import 'package:attendance/components/assets.dart';
import 'package:attendance/components/styles.dart';
import 'package:attendance/models/students_model.dart';
import 'package:attendance/screens/admin_view_attendance_screen.dart';
import 'package:attendance/screens/admin_view_student_screen.dart';
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
  final GlobalKey<FormState> _formKeyUpdateRemainingClasses =
      GlobalKey<FormState>();

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
  String? _selectedStudentIdForUpdate;
  int _newRemainingClasses = 0;

  final _snackbarUtil = SnackbarUtil();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchParentsAndStudents();
  }

  Future<void> _fetchParentsAndStudents() async {
    setState(() {
      _isLoading = true;
    });

    final fetchedParents = await FirebaseUtils.fetchParents();
    final fetchedStudents = await FirebaseUtils.fetchStudents();
    setState(() {
      _parents = fetchedParents;
      _parents.sort((a, b) => a['data'].parentName.compareTo(b['data'].parentName));
      _students = fetchedStudents;
      _students.sort((a, b) => a['data'].studentName.compareTo(b['data'].studentName));
      _isLoading = false;
    });
  }

  Future<void> _fetchParents() async {
    final fetchedParents = await FirebaseUtils.fetchParents();
    setState(() {
      _parents = fetchedParents;
      _parents.sort((a, b) => a['data'].parentName.compareTo(b['data'].parentName));

    });
  }

  Future<void> _fetchStudents() async {
    final fetchedStudents = await FirebaseUtils.fetchStudents();
    setState(() {
      _students = fetchedStudents;
      _students.sort((a, b) => a['data'].studentName.compareTo(b['data'].studentName));

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
    final List<TimeOfDay> predefinedTimes = [
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 11, minute: 30),
      TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 15, minute: 30),
      TimeOfDay(hour: 17, minute: 0),
    ];

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Time'),
          children: <Widget>[
            ...predefinedTimes.map((time) => SimpleDialogOption(
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        time.hour,
                        time.minute,
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('${time.format(context)}'),
                )),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                // Then call the standard TimePickerDialog
                showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                ).then((pickedTime) {
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
                });
              },
              child: const Text('Pick a custom time'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _selectTime(BuildContext context) async {
  //   final TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //   );
  //   if (pickedTime != null) {
  //     setState(() {
  //       _selectedDate = DateTime(
  //         _selectedDate.year,
  //         _selectedDate.month,
  //         _selectedDate.day,
  //         pickedTime.hour,
  //         pickedTime.minute,
  //       );
  //     });
  //   }
  // }

  Future<void> _addAttendance() async {
    if (_formKeyAttendance.currentState!.validate()) {
      FirebaseUtils.addAttendance(
        studentId: _selectedStudentId ?? "",
        parentId: _selectedParentId ?? "",
        attendanceDate: _selectedDate,
        isPresent: _isPresent,
        className: _selectedClassName ?? "",
        onSuccess: () async {
          if (mounted) {
            _snackbarUtil.showSnackbar(
                context, "Attendance recorded successfully");
            // Now, decrement the remaining classes for the student
            if (_selectedStudentId != null && _isPresent) {
              final DocumentReference studentRef = FirebaseFirestore.instance
                  .collection('students')
                  .doc(_selectedStudentId);
              FirebaseFirestore.instance.runTransaction((transaction) async {
                DocumentSnapshot studentSnapshot =
                    await transaction.get(studentRef);
                if (studentSnapshot.exists) {
                  int currentRemainingClasses =
                      studentSnapshot.get('remainingClasses');
                  if (currentRemainingClasses > 0) {
                    transaction.update(studentRef,
                        {'remainingClasses': currentRemainingClasses - 1});
                  }
                }
              }).then((value) {
                _snackbarUtil.showSnackbar(
                    context, "Remaining classes updated successfully");
              }).catchError((error) {
                _snackbarUtil.showSnackbar(
                    context, "Error updating remaining classes: $error");
              });
            }
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

  Future<void> _updateStudentRemainingClasses() async {
    if (_selectedStudentIdForUpdate != null) {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(_selectedStudentIdForUpdate)
          .update({
        'remainingClasses': _newRemainingClasses,
      }).then((_) {
        _snackbarUtil.showSnackbar(
            context, "Remaining classes updated successfully");
        _fetchStudents(); // Refresh the list of students
      }).catchError((error) {
        _snackbarUtil.showSnackbar(
            context, "Error updating remaining classes: $error");
      });

      // Reset the form and state
      setState(() {
        _selectedStudentIdForUpdate = null;
        _newRemainingClasses = 0;
      });
      _formKeyUpdateRemainingClasses.currentState?.reset();
    } else {
      _snackbarUtil.showSnackbar(context, "No student selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
        actions: [
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AdminViewUserScreen.id),
              icon: const Icon(Icons.people_rounded)),
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AdminViewStudentScreen.id),
              icon: const Icon(Icons.emoji_people)),
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AdminViewAttendanceScreen.id),
              icon: const Icon(Icons.list)),
        ],
        backgroundColor: kAppBarBackgroundColor,
      ),
      backgroundColor: kBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Form for creating a user
                    Form(
                      key:
                          _formKeyUser, // Unique GlobalKey<FormState> for this form
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            onChanged: (value) => _email = value,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter an email' : null,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: false,
                            onChanged: (value) => _password = value,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a password'
                                : null,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.name,
                            decoration:
                                const InputDecoration(labelText: 'Parent Name'),
                            onChanged: (value) => _parentName = value,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a parent name'
                                : null,
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
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                                labelText: 'Student Name'),
                            onChanged: (value) => _studentName = value,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a student name'
                                : null,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Remaining Classes'),
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
                                final String? parentId =
                                    studentData['parentId'];
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
                            decoration: const InputDecoration(
                                labelText: 'Select a Student'),
                            validator: (value) => value == null
                                ? 'Please select a student'
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
                            decoration: const InputDecoration(
                                labelText: 'Select a Parent'),
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
                                  if (picked != null &&
                                      picked != _selectedDate) {
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
                              'Digital Art Class',
                              'Make Up Class - Traditional',
                              'Make Up Class - Digital Art Class'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            validator: (value) => value == null
                                ? 'Please select a class name'
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Call the method to add attendance when the button is pressed
                                if (_formKeyAttendance.currentState!
                                    .validate()) {
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
                    // Form for updating remaining classes for a student
                    Form(
                      key: _formKeyUpdateRemainingClasses,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedStudentIdForUpdate,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStudentIdForUpdate = newValue;
                              });
                            },
                            items: _students.map((student) {
                              return DropdownMenuItem<String>(
                                value: student['id'],
                                child: Text(student['data'].studentName),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                                labelText: 'Select a Student for Update'),
                            validator: (value) => value == null
                                ? 'Please select a student'
                                : null,
                          ),
                          FutureBuilder<StudentModel?>(
                            future: FirebaseUtils.fetchStudentByID(
                                _selectedStudentIdForUpdate ??
                                    '0'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // Display a loading indicator or a placeholder while waiting for the future to complete
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                // Handle error state
                                return Text("Error fetching data");
                              } else if (snapshot.hasData) {
                                // Once the data is available, use it in the TextFormField
                                final remainingClasses = snapshot.data
                                    ?.remainingClasses; // Make sure this matches your data model
                                return TextFormField(
                                  decoration: InputDecoration(
                                    labelText:
                                        'Remaining Classes: $remainingClasses. Please ender a new remaining classes', 
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => _newRemainingClasses =
                                      int.tryParse(value) ?? 0,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                );
                              } else {
                                // Handle the case where there is no data
                                return Text("");
                              }
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Validate form and update student remaining classes
                              if (_formKeyUpdateRemainingClasses.currentState!
                                  .validate()) {
                                _updateStudentRemainingClasses();
                              }
                            },
                            child: const Text('Update Remaining Classes'),
                          ),
                          adminDivider,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
