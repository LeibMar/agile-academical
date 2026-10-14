
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:integration_test/integration_test.dart';

import 'package:agile_academical_app/core/bindings/app_binding.dart';
import 'package:agile_academical_app/domain/usecases/tasks/update_task.dart';
import 'package:agile_academical_app/firebase_options.dart';

void main() {
IntegrationTestWidgetsFlutterBinding.ensureInitialized();

setUpAll(() async {
await dotenv.load(fileName: 'assets/.env');

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

Get.reset();
AppBinding().dependencies();
});

tearDownAll(() {
Get.reset();
});

test('UpdateTask deve ser registrado no AppBinding', () {
final useCase = Get.find<UpdateTask>();

expect(useCase, isA<UpdateTask>());
});
}
