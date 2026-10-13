
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/project.dart';
import '../lib/domain/entities/task.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/project_repository.dart';
import '../lib/domain/repositories/task_repository.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TaskRepository taskRepository;
  late ProjectRepository projectRepository;
  late RegisterUser registerUser;
  late UserAuthDataSource authDataSource;

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/.env');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppBinding().dependencies();

    projectRepository = Get.find<ProjectRepository>();
    registerUser = Get.find<RegisterUser>();
    authDataSource = Get.find<UserAuthDataSource>();

    taskRepository = Get.find<TaskRepository>();
  });

  testWidgets(
    'deve realizar CRUD de tarefas vinculadas a um projeto',
        (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userEmail = 'task.test.$timestamp@example.com';
      const userPassword = 'Test@123456';

      String? projectId;
      String? firstTaskId;
      String? secondTaskId;

      try {
        // 1. Cria usuário de teste.
        final registeredUser = await registerUser.call(
          name: 'Usuário Teste Task',
          email: userEmail,
          password: userPassword,
          role: UserRole.student,
        );

        expect(registeredUser.uid, isNotEmpty);

        // 2. Cria projeto de teste.
        final project = Project(
          id: '',
          title: 'Projeto Teste Task',
          description: 'Projeto utilizado no teste de tarefas.',
          status: ProjectStatus.planning,
          ownerId: registeredUser.uid,
          advisorId: null,
          memberIds: [registeredUser.uid],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        projectId = await projectRepository.createProject(project);

        expect(projectId, isNotEmpty);

        // 3. Cria a primeira tarefa, ainda no backlog.
        final firstTask = Task(
          id: '',
          projectId: projectId,
          stageId: null,
          title: 'Definir requisitos',
          description: 'Levantar os requisitos do sistema.',
          status: TaskStatus.backlog,
          priority: TaskPriority.high,
          assignedTo: null,
          createdBy: registeredUser.uid,
          startDate: null,
          dueDate: DateTime(2026, 11, 10),
          completedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        firstTaskId = await taskRepository.createTask(firstTask);

        expect(firstTaskId, isNotEmpty);

        // 4. Cria uma segunda tarefa.
        final secondTask = Task(
          id: '',
          projectId: projectId,
          stageId: null,
          title: 'Implementar autenticação',
          description: 'Implementar o fluxo de autenticação.',
          status: TaskStatus.inProgress,
          priority: TaskPriority.medium,
          assignedTo: registeredUser.uid,
          createdBy: registeredUser.uid,
          startDate: DateTime(2026, 10, 12),
          dueDate: DateTime(2026, 11, 20),
          completedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        secondTaskId = await taskRepository.createTask(secondTask);

        expect(secondTaskId, isNotEmpty);
        expect(secondTaskId, isNot(firstTaskId));

        // 5. Lê a primeira tarefa.
        final retrievedFirstTask = await taskRepository.getTask(
          projectId,
          firstTaskId,
        );

        expect(retrievedFirstTask, isNotNull);
        expect(retrievedFirstTask!.id, firstTaskId);
        expect(retrievedFirstTask.projectId, projectId);
        expect(retrievedFirstTask.stageId, isNull);
        expect(retrievedFirstTask.title, 'Definir requisitos');
        expect(
          retrievedFirstTask.description,
          'Levantar os requisitos do sistema.',
        );
        expect(retrievedFirstTask.status, TaskStatus.backlog);
        expect(retrievedFirstTask.priority, TaskPriority.high);
        expect(retrievedFirstTask.assignedTo, isNull);
        expect(retrievedFirstTask.createdBy, registeredUser.uid);
        expect(
          retrievedFirstTask.dueDate,
          DateTime(2026, 11, 10),
        );
        expect(retrievedFirstTask.createdAt, isNotNull);
        expect(retrievedFirstTask.updatedAt, isNotNull);

        // 6. Lista as tarefas do projeto.
        final tasks = await taskRepository.getTasksForProject(projectId);

        expect(tasks.length, 2);
        expect(
          tasks.map((task) => task.id),
          containsAll([firstTaskId, secondTaskId]),
        );

        // 7. Atualiza a segunda tarefa.
        final updatedSecondTask = Task(
          id: secondTaskId,
          projectId: projectId,
          stageId: null,
          title: 'Implementar autenticação atualizada',
          description: 'Implementar autenticação e validar os testes.',
          status: TaskStatus.inReview,
          priority: TaskPriority.critical,
          assignedTo: registeredUser.uid,
          createdBy: registeredUser.uid,
          startDate: DateTime(2026, 10, 12),
          dueDate: DateTime(2026, 11, 25),
          completedAt: null,
          createdAt: secondTask.createdAt,
          updatedAt: DateTime.now(),
        );

        await taskRepository.updateTask(updatedSecondTask);

        // 8. Confirma a atualização.
        final retrievedUpdatedTask = await taskRepository.getTask(
          projectId,
          secondTaskId,
        );

        expect(retrievedUpdatedTask, isNotNull);
        expect(
          retrievedUpdatedTask!.title,
          'Implementar autenticação atualizada',
        );
        expect(
          retrievedUpdatedTask.description,
          'Implementar autenticação e validar os testes.',
        );
        expect(retrievedUpdatedTask.status, TaskStatus.inReview);
        expect(retrievedUpdatedTask.priority, TaskPriority.critical);
        expect(
          retrievedUpdatedTask.dueDate,
          DateTime(2026, 11, 25),
        );
        expect(
          retrievedUpdatedTask.assignedTo,
          registeredUser.uid,
        );
        expect(retrievedUpdatedTask.createdAt, isNotNull);
        expect(retrievedUpdatedTask.updatedAt, isNotNull);

        // 9. Exclui a primeira tarefa.
        await taskRepository.deleteTask(projectId, firstTaskId);

        final deletedTask = await taskRepository.getTask(
          projectId,
          firstTaskId,
        );

        expect(deletedTask, isNull);

        // 10. Confirma que a segunda tarefa continua existindo.
        final remainingTasks =
        await taskRepository.getTasksForProject(projectId);

        expect(remainingTasks.length, 1);
        expect(remainingTasks.single.id, secondTaskId);

        // 11. Exclui a segunda tarefa.
        await taskRepository.deleteTask(projectId, secondTaskId);

        final tasksAfterDeletion =
        await taskRepository.getTasksForProject(projectId);

        expect(tasksAfterDeletion, isEmpty);

        // 12. Exclui o projeto de teste.
        await projectRepository.deleteProject(projectId);

        final deletedProject =
        await projectRepository.getProject(projectId);

        expect(deletedProject, isNull);

        projectId = null;
        firstTaskId = null;
        secondTaskId = null;
      } finally {
        // Limpeza caso alguma etapa do teste falhe.
        if (projectId != null) {
          if (firstTaskId != null) {
            await taskRepository.deleteTask(projectId, firstTaskId);
          }

          if (secondTaskId != null) {
            await taskRepository.deleteTask(projectId, secondTaskId);
          }

          await projectRepository.deleteProject(projectId);
        }

        await authDataSource.deleteCurrentUser();
      }
    },
  );
}
