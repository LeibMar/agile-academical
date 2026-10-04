import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

abstract class AuthRepository {
  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
  });

  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  firebase_auth.User? get currentUser;

  Future<void> deleteCurrentUser();
}