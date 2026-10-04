import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

class RegisterUser {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  RegisterUser({
    required this.authRepository,
    required this.userRepository,
  });

  Future<User> call({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? photoUrl,
  }) async {
    firebase_auth.UserCredential credential;

    try {
      credential = await authRepository.createAccount(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    }

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception(
        'O Firebase Authentication não retornou um usuário válido.',
      );
    }

    final now = DateTime.now();

    final user = User(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      role: role,
      photoUrl: photoUrl,
      active: true,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await userRepository.createUser(user);
    } catch (error) {
      try {
        await authRepository.deleteCurrentUser();
      } catch (_) {
        // A conta pode permanecer no Authentication caso a exclusão
        // também falhe. O erro original do Firestore será propagado.
      }

      rethrow;
    }

    return user;
  }
}