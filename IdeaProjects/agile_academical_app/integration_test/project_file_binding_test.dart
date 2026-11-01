import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:agile_academical_app/core/bindings/app_binding.dart';
import 'package:agile_academical_app/data/datasources/project_file_firestore_datasource.dart';
import 'package:agile_academical_app/data/repositories/project_file_repository_impl.dart';
import 'package:agile_academical_app/domain/repositories/project_file_repository.dart';
import 'package:agile_academical_app/domain/usecases/files/create_project_file.dart';
import 'package:agile_academical_app/domain/usecases/files/get_project_file.dart';
import 'package:agile_academical_app/domain/usecases/files/get_project_files.dart';
import 'package:agile_academical_app/domain/usecases/files/get_project_files_for_related_entity.dart';
import 'package:agile_academical_app/domain/usecases/files/update_project_file.dart';
import 'package:agile_academical_app/domain/usecases/files/delete_project_file.dart';
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
    'deve resolver dependências do módulo File pelo AppBinding',
        (tester) async {
      // Use cases
      expect(
        Get.find<CreateProjectFile>(),
        isA<CreateProjectFile>(),
      );

      expect(
        Get.find<GetProjectFile>(),
        isA<GetProjectFile>(),
      );

      expect(
        Get.find<GetProjectFiles>(),
        isA<GetProjectFiles>(),
      );

      expect(
        Get.find<GetProjectFilesForRelatedEntity>(),
        isA<GetProjectFilesForRelatedEntity>(),
      );

      expect(
        Get.find<UpdateProjectFile>(),
        isA<UpdateProjectFile>(),
      );

      expect(
        Get.find<DeleteProjectFile>(),
        isA<DeleteProjectFile>(),
      );

      // Repository
      expect(
        Get.find<ProjectFileRepository>(),
        isA<ProjectFileRepositoryImpl>(),
      );

      // Data source
      expect(
        Get.find<ProjectFileFirestoreDataSource>(),
        isA<ProjectFileFirestoreDataSource>(),
      );
    },
  );
}