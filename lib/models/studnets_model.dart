// students_model.dart
class StudentModel {
  String parentId;
  String studentName;
  int remainingClasses;

  StudentModel({
    required this.parentId,
    required this.studentName,
    required this.remainingClasses,
  });

  Map<String, dynamic> toJson() => {
        'parentId': parentId,
        'studentName': studentName,
        'remainingClasses': remainingClasses,
      };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        parentId: json['parentId'],
        studentName: json['studentName'],
        remainingClasses: json['remainingClasses'],
      );
}

