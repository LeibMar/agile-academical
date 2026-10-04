
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/user_repository.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
IntegrationTestWidgetsFlutterBinding.ensureInitialized();

late RegisterUser registerUser;
late UserRepository userRepository;
late UserAuthDataSource authDataSource;

setUpAll(() async {
await dotenv.load(fileName: 'assets/.env');

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

AppBinding().dependencies();

registerUser = Get.find<RegisterUser>();
userRepository = Get.find<UserRepository>();
authDataSource = Get.find<UserAuthDataSource>();
});

testWidgets(
'deve executar CRUD completo do usuário',
(WidgetTester tester) async {
final timestamp = DateTime.now().millisecondsSinceEpoch;

final email = 'crud.$timestamp@agileacademical.com';
const password = 'Teste@123456';
const name = 'Usuário CRUD';

// ============================================================
// PREPARAÇÃO
// ============================================================

final createdUser = await registerUser.call(
name: name,
email: email,
password: password,
role: UserRole.student,
);

expect(createdUser.uid, isNotEmpty);

// ============================================================
// READ
// ============================================================

final readUser = await userRepository.getUser(
createdUser.uid,
);

expect(readUser, isNotNull);

expect(
readUser!.uid,
equals(createdUser.uid),
);

expect(
readUser.name,
equals(name),
);

expect(
readUser.email,
equals(email),
);

expect(
readUser.role,
equals(UserRole.student),
);

expect(
readUser.active,
isTrue,
);

// ============================================================
// UPDATE
// ============================================================

final updatedUser = User(
uid: createdUser.uid,
name: 'Usuário Atualizado',
email: createdUser.email,
role: createdUser.role,
photoUrl: createdUser.photoUrl,
active: createdUser.active,
createdAt: createdUser.createdAt,
updatedAt: DateTime.now(),
);

await userRepository.updateUser(updatedUser);

final userAfterUpdate = await userRepository.getUser(
createdUser.uid,
);

expect(userAfterUpdate, isNotNull);

expect(
userAfterUpdate!.uid,
equals(createdUser.uid),
);

expect(
userAfterUpdate.name,
equals('Usuário Atualizado'),
);

expect(
userAfterUpdate.email,
equals(createdUser.email),
);

expect(
userAfterUpdate.role,
equals(createdUser.role),
);

expect(
userAfterUpdate.active,
isTrue,
);

// ============================================================
// DELETE LÓGICO
// ============================================================

await userRepository.deactivateUser(
createdUser.uid,
);

final userAfterDeactivate = await userRepository.getUser(
createdUser.uid,
);

expect(userAfterDeactivate, isNotNull);

expect(
userAfterDeactivate!.active,
isFalse,
);

// ============================================================
// LIMPEZA DO FIREBASE AUTHENTICATION
// ============================================================

await authDataSource.deleteCurrentUser();

expect(
authDataSource.currentUser,
isNull,
);
},
);
}

