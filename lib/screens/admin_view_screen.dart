import 'package:attendance/utils/firebase_utils.dart';
import 'package:flutter/material.dart';

class AdminViewScreen extends StatefulWidget {
  const AdminViewScreen({super.key});

  static String id = 'AdminViewScreen';

  @override
  State<AdminViewScreen> createState() => _AdminViewScreenState();
}

class _AdminViewScreenState extends State<AdminViewScreen> {
  List<Map<String, dynamic>> _parents = [];
  List<Map<String, dynamic>> _students = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _parents.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Text('${_parents[index]}'),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Text('${_students[index]}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
