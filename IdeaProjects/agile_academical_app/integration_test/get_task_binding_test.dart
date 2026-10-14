
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:agile_academical_app/core/bindings/app_binding.dart';
import 'package:agile_academical_app/domain/usecases/tasks/get_task.dart';

import 'package:agile_academical_app/data/datasources/task_firestore_datasource.dart';
import 'package:agile_academical_app/domain/repositories/task_repository.dart';
import 'package:agile_academical_app/data/repositories/task_repository_impl.dart';
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

  testWidgets(
    'deve resolver CreateTask pelo AppBinding',
        (tester) async {
          final getTask = Get.find<GetTask>();

          expect(getTask, isA<GetTask>());
          expect(
            Get.find<TaskRepository>(),
            isA<TaskRepository>(),
          );

      expect(
        Get.find<TaskFirestoreDataSource>(),
        isA<TaskFirestoreDataSource>(),
      );
    },
  );
}
