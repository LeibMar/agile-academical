
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:agile_academical_app/core/bindings/app_binding.dart';
import 'package:agile_academical_app/data/datasources/project_firestore_datasource.dart';
import 'package:agile_academical_app/data/repositories/project_repository_impl.dart';
import 'package:agile_academical_app/domain/repositories/project_repository.dart';
import 'package:agile_academical_app/domain/usecases/projects/create_project.dart';
import 'package:agile_academical_app/domain/usecases/projects/get_project.dart';
import 'package:agile_academical_app/domain/usecases/projects/get_projects_for_user.dart';
import 'package:agile_academical_app/domain/usecases/projects/update_project.dart';
import 'package:agile_academical_app/domain/usecases/projects/add_project_member.dart';
import 'package:agile_academical_app/domain/usecases/projects/remove_project_member.dart';
import 'package:agile_academical_app/domain/usecases/projects/cancel_project.dart';
import 'package:agile_academical_app/domain/usecases/projects/delete_project.dart';
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
    'deve resolver os casos de uso de projeto pelo AppBinding',
        (tester) async {
      expect(Get.find<CreateProject>(), isA<CreateProject>());
      expect(Get.find<GetProject>(), isA<GetProject>());
      expect(
        Get.find<GetProjectsForUser>(),
        isA<GetProjectsForUser>(),
      );
      expect(Get.find<UpdateProject>(), isA<UpdateProject>());
      expect(
        Get.find<AddProjectMember>(),
        isA<AddProjectMember>(),
      );
      expect(
        Get.find<RemoveProjectMember>(),
        isA<RemoveProjectMember>(),
      );
      expect(Get.find<CancelProject>(), isA<CancelProject>());
      expect(Get.find<DeleteProject>(), isA<DeleteProject>());

      expect(
        Get.find<ProjectRepository>(),
        isA<ProjectRepositoryImpl>(),
      );

      expect(
        Get.find<ProjectFirestoreDataSource>(),
        isA<ProjectFirestoreDataSource>(),
      );
    },
  );
}
