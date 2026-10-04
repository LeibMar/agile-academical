enum UserRole {
  student,
  advisor,
}

class User {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });
}