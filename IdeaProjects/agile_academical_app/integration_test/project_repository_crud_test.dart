
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/project.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/project_repository.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
IntegrationTestWidgetsFlutterBinding.ensureInitialized();

late RegisterUser registerUser;
late ProjectRepository projectRepository;
late UserAuthDataSource authDataSource;

setUpAll(() async {
await dotenv.load(fileName: 'assets/.env');

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

AppBinding().dependencies();

registerUser = Get.find<RegisterUser>();
projectRepository = Get.find<ProjectRepository>();
authDataSource = Get.find<UserAuthDataSource>();
});

testWidgets(
'deve executar CRUD completo do projeto',
(WidgetTester tester) async {
final timestamp = DateTime.now().millisecondsSinceEpoch;

final email = 'project.$timestamp@agileacademical.com';
const password = 'Teste@123456';

// ============================================================
// PREPARAÇÃO
// ============================================================

final user = await registerUser.call(
name: 'Usuário do Projeto',
email: email,
password: password,
role: UserRole.student,
);

expect(user.uid, isNotEmpty);

// ============================================================
// CREATE
// ============================================================

final project = Project(
id: '',
title: 'Projeto de Teste',
description: 'Projeto criado pelo teste de integração.',
status: ProjectStatus.planning,
ownerId: user.uid,
advisorId: null,
memberIds: [user.uid],
createdAt: DateTime.now(),
updatedAt: DateTime.now(),
);

final projectId = await projectRepository.createProject(
project,
);

expect(projectId, isNotEmpty);

// ============================================================
// READ
// ============================================================

final createdProject = await projectRepository.getProject(
projectId,
);

expect(createdProject, isNotNull);

expect(
createdProject!.id,
equals(projectId),
);

expect(
createdProject.title,
equals('Projeto de Teste'),
);

expect(
createdProject.description,
equals('Projeto criado pelo teste de integração.'),
);

expect(
createdProject.status,
equals(ProjectStatus.planning),
);

expect(
createdProject.ownerId,
equals(user.uid),
);

expect(
createdProject.advisorId,
isNull,
);

expect(
createdProject.memberIds,
contains(user.uid),
);

// ============================================================
// GET PROJECTS FOR USER
// ============================================================

final userProjects = await projectRepository.getProjectsForUser(
user.uid,
);

expect(
userProjects.any(
(project) => project.id == projectId,
),
isTrue,
);

// ============================================================
// UPDATE
// ============================================================

final updatedProject = Project(
id: projectId,
title: 'Projeto Atualizado',
description: 'Descrição atualizada pelo teste.',
status: ProjectStatus.inProgress,
ownerId: user.uid,
advisorId: null,
memberIds: [user.uid],
createdAt: createdProject.createdAt,
updatedAt: DateTime.now(),
);

await projectRepository.updateProject(
updatedProject,
);

final projectAfterUpdate =
await projectRepository.getProject(projectId);

expect(projectAfterUpdate, isNotNull);

expect(
projectAfterUpdate!.title,
equals('Projeto Atualizado'),
);

expect(
projectAfterUpdate.description,
equals('Descrição atualizada pelo teste.'),
);

expect(
projectAfterUpdate.status,
equals(ProjectStatus.inProgress),
);

// ============================================================
// CANCEL PROJECT
// ============================================================

await projectRepository.cancelProject(
projectId,
);

final projectAfterCancel =
await projectRepository.getProject(projectId);

expect(projectAfterCancel, isNotNull);

expect(
projectAfterCancel!.status,
equals(ProjectStatus.cancelled),
);

// ============================================================
// DELETE
// ============================================================

await projectRepository.deleteProject(
projectId,
);

final deletedProject =
await projectRepository.getProject(projectId);

expect(
deletedProject,
isNull,
);

// ============================================================
// LIMPEZA DO AUTHENTICATION
// ============================================================

await authDataSource.deleteCurrentUser();

expect(
authDataSource.currentUser,
isNull,
);
},
);
}

