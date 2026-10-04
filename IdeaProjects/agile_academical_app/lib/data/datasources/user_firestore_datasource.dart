import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserFirestoreDataSource {
  final FirebaseFirestore firestore;

  UserFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromFirestore(doc);
  }

  Future<List<UserModel>> getUsers() async {
    final snapshot = await _users
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map(UserModel.fromFirestore)
        .toList();
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.uid).update({
      'name': user.name,
      'email': user.email,
      'role': user.role.name,
      'photoUrl': user.photoUrl,
      'active': user.active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deactivateUser(String uid) async {
    await _users.doc(uid).update({
      'active': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}