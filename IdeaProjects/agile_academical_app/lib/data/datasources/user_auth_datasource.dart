import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserAuthDataSource {
  final firebase_auth.FirebaseAuth auth;

  UserAuthDataSource({
    firebase_auth.FirebaseAuth? auth,
  }) : auth = auth ?? firebase_auth.FirebaseAuth.instance;

  firebase_auth.User? get currentUser => auth.currentUser;

  Future<firebase_auth.UserCredential> createUser({
    required String email,
    required String password,
  }) {
    return auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return auth.signOut();
  }

  Future<void> deleteCurrentUser() async {
    final user = auth.currentUser;

    if (user == null) {
      return;
    }

    await user.delete();
  }
}