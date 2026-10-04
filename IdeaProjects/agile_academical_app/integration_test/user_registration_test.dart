
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/auth_repository.dart';
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
'deve registrar usuário no Authentication e no Firestore',
(WidgetTester tester) async {
final timestamp = DateTime.now().millisecondsSinceEpoch;

final email = 'teste.$timestamp@agileacademical.com';
const password = 'Teste@123456';
const name = 'Usuário de Teste';

// ------------------------------------------------------------
// CREATE
// ------------------------------------------------------------

final createdUser = await registerUser.call(
name: name,
email: email,
password: password,
role: UserRole.student,
);

// ------------------------------------------------------------
// VALIDAR FIREBASE AUTHENTICATION
// ------------------------------------------------------------

expect(createdUser.uid, isNotEmpty);
expect(authDataSource.currentUser, isNotNull);

expect(
authDataSource.currentUser!.uid,
equals(createdUser.uid),
);

// ------------------------------------------------------------
// VALIDAR ENTIDADE RETORNADA
// ------------------------------------------------------------

expect(createdUser.name, equals(name));
expect(createdUser.email, equals(email));
expect(createdUser.role, equals(UserRole.student));
expect(createdUser.active, isTrue);

// ------------------------------------------------------------
// VALIDAR FIRESTORE
// ------------------------------------------------------------

final firestoreUser = await userRepository.getUser(
createdUser.uid,
);

expect(firestoreUser, isNotNull);

expect(
firestoreUser!.uid,
equals(createdUser.uid),
);

expect(
firestoreUser.name,
equals(name),
);

expect(
firestoreUser.email,
equals(email),
);

expect(
firestoreUser.role,
equals(UserRole.student),
);

expect(
firestoreUser.active,
isTrue,
);
},
);
}

