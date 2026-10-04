
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
'deve criar, alterar e remover orientador de um projeto',
(WidgetTester tester) async {
final timestamp = DateTime.now().millisecondsSinceEpoch;

// ============================================================
// PREPARAÇÃO - ALUNO / OWNER
// ============================================================

final owner = await registerUser.call(
name: 'Aluno do Projeto',
email: 'advisor.owner.$timestamp@agileacademical.com',
password: 'Teste@123456',
role: UserRole.student,
);

expect(owner.uid, isNotEmpty);

// ============================================================
// PREPARAÇÃO - ORIENTADOR 1
// ============================================================

await authDataSource.deleteCurrentUser();

final advisor1 = await registerUser.call(
name: 'Orientador 1',
email: 'advisor.one.$timestamp@agileacademical.com',
password: 'Teste@123456',
role: UserRole.advisor,
);

expect(advisor1.uid, isNotEmpty);

expect(
advisor1.uid,
isNot(equals(owner.uid)),
);

// ============================================================
// PREPARAÇÃO - ORIENTADOR 2
// ============================================================

await authDataSource.deleteCurrentUser();

final advisor2 = await registerUser.call(
name: 'Orientador 2',
email: 'advisor.two.$timestamp@agileacademical.com',
password: 'Teste@123456',
role: UserRole.advisor,
);

expect(advisor2.uid, isNotEmpty);

expect(
advisor2.uid,
isNot(equals(owner.uid)),
);

expect(
advisor2.uid,
isNot(equals(advisor1.uid)),
);

// ============================================================
// CREATE PROJECT
// ============================================================

final project = Project(
id: '',
title: 'Projeto com Orientador',
description: 'Projeto criado para testar a relação de orientação.',
status: ProjectStatus.planning,
ownerId: owner.uid,
advisorId: advisor1.uid,
memberIds: [owner.uid],
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

final createdProject =
await projectRepository.getProject(projectId);

expect(createdProject, isNotNull);

expect(
createdProject!.ownerId,
equals(owner.uid),
);

expect(
createdProject.advisorId,
equals(advisor1.uid),
);

expect(
createdProject.memberIds,
contains(owner.uid),
);

// ============================================================
// VERIFICAR QUE O ORIENTADOR NÃO É MEMBRO AUTOMATICAMENTE
// ============================================================

expect(
createdProject.memberIds,
isNot(contains(advisor1.uid)),
);

// ============================================================
// ALTERAR ORIENTADOR
// ============================================================

final projectWithNewAdvisor = Project(
id: projectId,
title: createdProject.title,
description: createdProject.description,
status: createdProject.status,
ownerId: createdProject.ownerId,
advisorId: advisor2.uid,
memberIds: createdProject.memberIds,
createdAt: createdProject.createdAt,
updatedAt: DateTime.now(),
);

await projectRepository.updateProject(
projectWithNewAdvisor,
);

final projectAfterAdvisorUpdate =
await projectRepository.getProject(projectId);

expect(
projectAfterAdvisorUpdate,
isNotNull,
);

expect(
projectAfterAdvisorUpdate!.advisorId,
equals(advisor2.uid),
);

expect(
projectAfterAdvisorUpdate.advisorId,
isNot(equals(advisor1.uid)),
);

// O novo orientador continua não sendo membro automaticamente.
expect(
projectAfterAdvisorUpdate.memberIds,
isNot(contains(advisor2.uid)),
);

// ============================================================
// REMOVER ORIENTADOR
// ============================================================

final projectWithoutAdvisor = Project(
id: projectId,
title: projectAfterAdvisorUpdate.title,
description: projectAfterAdvisorUpdate.description,
status: projectAfterAdvisorUpdate.status,
ownerId: projectAfterAdvisorUpdate.ownerId,
advisorId: null,
memberIds: projectAfterAdvisorUpdate.memberIds,
createdAt: projectAfterAdvisorUpdate.createdAt,
updatedAt: DateTime.now(),
);

await projectRepository.updateProject(
projectWithoutAdvisor,
);

final projectAfterAdvisorRemoval =
await projectRepository.getProject(projectId);

expect(
projectAfterAdvisorRemoval,
isNotNull,
);

expect(
projectAfterAdvisorRemoval!.advisorId,
isNull,
);

// O owner continua sendo membro.
expect(
projectAfterAdvisorRemoval.memberIds,
contains(owner.uid),
);

// ============================================================
// CLEANUP - PROJECT
// ============================================================

await projectRepository.deleteProject(projectId);

final deletedProject =
await projectRepository.getProject(projectId);

expect(
deletedProject,
isNull,
);

// ============================================================
// CLEANUP - USUÁRIO AUTENTICADO
// ============================================================

await authDataSource.deleteCurrentUser();

expect(
authDataSource.currentUser,
isNull,
);
},
);
}

