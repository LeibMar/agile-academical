import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    super.photoUrl,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      role: user.role,
      photoUrl: user.photoUrl,
      active: user.active,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return UserModel(
      uid: doc.id,
      name: data['name'],
      email: data['email'],
      role: _roleFromString(data['role']),
      photoUrl: data['photoUrl'],
      active: data['active'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'photoUrl': photoUrl,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static UserRole _roleFromString(String value) {
    switch (value) {
      case 'advisor':
        return UserRole.advisor;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}