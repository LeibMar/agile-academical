import '../entities/user.dart';

abstract class UserRepository {
  Future<void> createUser(User user);

  Future<User?> getUser(String uid);

  Future<User?> getCurrentUser();

  Future<List<User>> getUsers();

  Future<void> updateUser(User user);

  Future<void> deactivateUser(String uid);
}