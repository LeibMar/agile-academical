import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/project.dart';
import '../lib/domain/entities/stage.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/project_repository.dart';
import '../lib/domain/repositories/stage_repository.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late StageRepository stageRepository;
  late ProjectRepository projectRepository;
  late RegisterUser registerUser;
  late UserAuthDataSource authDataSource;

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/.env');


    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppBinding().dependencies();

    stageRepository = Get.find<StageRepository>();
    projectRepository = Get.find<ProjectRepository>();
    registerUser = Get.find<RegisterUser>();
    authDataSource = Get.find<UserAuthDataSource>();


  });

  testWidgets(
    'deve realizar CRUD de uma etapa vinculada a um projeto',
        (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;


      final userEmail = 'stage.test.$timestamp@example.com';
      const userPassword = 'Test@123456';

      String? projectId;

      try {
        // ------------------------------------------------------------
        // 1. Cria usuário de teste
        // ------------------------------------------------------------

        final registeredUser = await registerUser.call(
          name: 'Usuário Teste Stage',
          email: userEmail,
          password: userPassword,
          role: UserRole.student,
        );

        expect(registeredUser.uid, isNotEmpty);

        // ------------------------------------------------------------
        // 2. Cria projeto de teste
        // ------------------------------------------------------------

        final project = Project(
          id: '',
          title: 'Projeto Teste Stage',
          description: 'Projeto utilizado no teste de etapas.',
          status: ProjectStatus.planning,
          ownerId: registeredUser.uid,
          advisorId: null,
          memberIds: [registeredUser.uid],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        projectId = await projectRepository.createProject(project);

        expect(projectId, isNotEmpty);

        // ------------------------------------------------------------
        // 3. Cria primeira etapa
        // ------------------------------------------------------------

        final firstStage = Stage(
          id: '',
          projectId: projectId,
          title: 'Planejamento',
          description: 'Definição inicial do projeto.',
          status: StageStatus.completed,
          order: 1,
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 10),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final firstStageId = await stageRepository.createStage(
          firstStage,
        );

        expect(firstStageId, isNotEmpty);

        // ------------------------------------------------------------
        // 4. Cria segunda etapa
        // ------------------------------------------------------------

        final secondStage = Stage(
          id: '',
          projectId: projectId,
          title: 'Desenvolvimento',
          description: 'Implementação do sistema.',
          status: StageStatus.inProgress,
          order: 2,
          startDate: DateTime(2026, 9, 11),
          endDate: DateTime(2026, 10, 10),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final secondStageId = await stageRepository.createStage(
          secondStage,
        );

        expect(secondStageId, isNotEmpty);

        // ------------------------------------------------------------
        // 5. Lê primeira etapa
        // ------------------------------------------------------------

        final retrievedFirstStage = await stageRepository.getStage(
          projectId,
          firstStageId,
        );

        expect(retrievedFirstStage, isNotNull);
        expect(retrievedFirstStage!.id, firstStageId);
        expect(retrievedFirstStage.projectId, projectId);
        expect(retrievedFirstStage.title, 'Planejamento');
        expect(
          retrievedFirstStage.status,
          StageStatus.completed,
        );
        expect(retrievedFirstStage.order, 1);
        expect(
          retrievedFirstStage.startDate,
          DateTime(2026, 9, 1),
        );
        expect(
          retrievedFirstStage.endDate,
          DateTime(2026, 9, 10),
        );

        // ------------------------------------------------------------
        // 6. Lista etapas do projeto
        // ------------------------------------------------------------

        final stages = await stageRepository.getStagesForProject(
          projectId,
        );

        expect(stages.length, 2);
        expect(stages[0].id, firstStageId);
        expect(stages[0].order, 1);
        expect(stages[1].id, secondStageId);
        expect(stages[1].order, 2);

        // ------------------------------------------------------------
        // 7. Atualiza segunda etapa
        // ------------------------------------------------------------

        final updatedSecondStage = Stage(
          id: secondStageId,
          projectId: projectId,
          title: 'Desenvolvimento Atualizado',
          description: 'Implementação e testes do sistema.',
          status: StageStatus.completed,
          order: 2,
          startDate: DateTime(2026, 9, 11),
          endDate: DateTime(2026, 10, 20),
          createdAt: secondStage.createdAt,
          updatedAt: DateTime.now(),
        );

        await stageRepository.updateStage(
          updatedSecondStage,
        );

        // ------------------------------------------------------------
        // 8. Verifica atualização
        // ------------------------------------------------------------

        final retrievedUpdatedStage =
        await stageRepository.getStage(
          projectId,
          secondStageId,
        );

        expect(retrievedUpdatedStage, isNotNull);
        expect(
          retrievedUpdatedStage!.title,
          'Desenvolvimento Atualizado',
        );
        expect(
          retrievedUpdatedStage.description,
          'Implementação e testes do sistema.',
        );
        expect(
          retrievedUpdatedStage.status,
          StageStatus.completed,
        );
        expect(retrievedUpdatedStage.order, 2);
        expect(
          retrievedUpdatedStage.endDate,
          DateTime(2026, 10, 20),
        );

        // ------------------------------------------------------------
// 9. Altera a ordem das etapas
// ------------------------------------------------------------

        final reorderedSecondStage = Stage(
          id: secondStageId,
          projectId: projectId,
          title: 'Desenvolvimento Atualizado',
          description: 'Implementação e testes do sistema.',
          status: StageStatus.completed,
          order: 1,
          startDate: DateTime(2026, 9, 11),
          endDate: DateTime(2026, 10, 20),
          createdAt: secondStage.createdAt,
          updatedAt: DateTime.now(),
        );

        await stageRepository.updateStage(
          reorderedSecondStage,
        );

        final reorderedFirstStage = Stage(
          id: firstStageId,
          projectId: projectId,
          title: 'Planejamento',
          description: 'Definição inicial do projeto.',
          status: StageStatus.completed,
          order: 2,
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 10),
          createdAt: firstStage.createdAt,
          updatedAt: DateTime.now(),
        );

        await stageRepository.updateStage(
          reorderedFirstStage,
        );

        // ------------------------------------------------------------
// 10. Verifica a nova ordenação
// ------------------------------------------------------------

        final reorderedStages =
        await stageRepository.getStagesForProject(
          projectId,
        );

        expect(reorderedStages.length, 2);

        expect(reorderedStages[0].id, secondStageId);
        expect(reorderedStages[0].order, 1);

        expect(reorderedStages[1].id, firstStageId);
        expect(reorderedStages[1].order, 2);

        // ------------------------------------------------------------
        // 11. Exclui primeira etapa
        // ------------------------------------------------------------

        await stageRepository.deleteStage(
          projectId,
          firstStageId,
        );

        final deletedStage = await stageRepository.getStage(
          projectId,
          firstStageId,
        );

        expect(deletedStage, isNull);

        // ------------------------------------------------------------
        // 12. Confirma que a segunda etapa continua existindo
        // ------------------------------------------------------------

        final remainingStages =
        await stageRepository.getStagesForProject(
          projectId,
        );

        expect(remainingStages.length, 1);
        expect(remainingStages.first.id, secondStageId);

        // ------------------------------------------------------------
        // 13. Exclui projeto
        // ------------------------------------------------------------

        await projectRepository.deleteProject(projectId);

        final deletedProject =
        await projectRepository.getProject(projectId);

        expect(deletedProject, isNull);

        // Verifica que as etapas do projeto também foram excluídas.
        final remainingStagesAfterProjectDeletion =
        await stageRepository.getStagesForProject(projectId);

        expect(remainingStagesAfterProjectDeletion, isEmpty);



        projectId = null;
      } finally {
        // ------------------------------------------------------------
        // Limpeza
        // ------------------------------------------------------------

        if (projectId != null) {
          await projectRepository.deleteProject(projectId);
        }

        await authDataSource.deleteCurrentUser();
      }
    },


  );

}
