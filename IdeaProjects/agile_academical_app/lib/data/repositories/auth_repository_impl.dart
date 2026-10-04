import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/repositories/auth_repository.dart';
import '../datasources/user_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserAuthDataSource dataSource;

  AuthRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    return dataSource.createUser(
      email: email,
      password: password,
    );
  }

  @override
  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return dataSource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() {
    return dataSource.signOut();
  }

  @override
  firebase_auth.User? get currentUser {
    return dataSource.currentUser;
  }

  @override
  Future<void> deleteCurrentUser() {
    return dataSource.deleteCurrentUser();
  }
}