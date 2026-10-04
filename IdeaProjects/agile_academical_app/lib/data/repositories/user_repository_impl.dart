import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_auth_datasource.dart';
import '../datasources/user_firestore_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserFirestoreDataSource firestoreDataSource;
  final UserAuthDataSource authDataSource;

  UserRepositoryImpl({
    required this.firestoreDataSource,
    required this.authDataSource,
  });

  @override
  Future<void> createUser(User user) {
    final model = UserModel.fromEntity(user);

    return firestoreDataSource.createUser(model);
  }

  @override
  Future<User?> getUser(String uid) {
    return firestoreDataSource.getUser(uid);
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = authDataSource.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return firestoreDataSource.getUser(firebaseUser.uid);
  }

  @override
  Future<List<User>> getUsers() {
    return firestoreDataSource.getUsers();
  }

  @override
  Future<void> updateUser(User user) {
    final model = UserModel.fromEntity(user);

    return firestoreDataSource.updateUser(model);
  }

  @override
  Future<void> deactivateUser(String uid) {
    return firestoreDataSource.deactivateUser(uid);
  }
}