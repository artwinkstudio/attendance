// users_model.dart
class UserModel {
  String email;
  String parentName;
  List<String> studentIDs; // Assuming this will store student IDs

  UserModel({
    required this.email,
    required this.parentName,
    required this.studentIDs,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'parentName': parentName,
        'students': studentIDs,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'],
        parentName: json['parentName'],
        studentIDs: List<String>.from(json['studentIDs']),
      );
}
