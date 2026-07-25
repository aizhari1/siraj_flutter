enum UserRole { student, teacher, admin, support }

UserRole userRoleFromString(String? value) {
  switch (value) {
    case 'TEACHER':
      return UserRole.teacher;
    case 'ADMIN':
      return UserRole.admin;
    case 'SUPPORT':
      return UserRole.support;
    case 'STUDENT':
    default:
      return UserRole.student;
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final UserRole role;
  final bool isActive;
  final String? bio;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      role: userRoleFromString(json['role']),
      isActive: json['isActive'] ?? true,
      bio: json['bio'],
    );
  }
}
