
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
'deve adicionar e remover membros de um projeto',
(WidgetTester tester) async {
final timestamp = DateTime.now().millisecondsSinceEpoch;

// ============================================================
// PREPARAÇÃO - USUÁRIO A / PROPRIETÁRIO
// ============================================================

final owner = await registerUser.call(
name: 'Proprietário do Projeto',
email: 'owner.$timestamp@agileacademical.com',
password: 'Teste@123456',
role: UserRole.student,
);

expect(owner.uid, isNotEmpty);

// ============================================================
// PREPARAÇÃO - USUÁRIO B / MEMBRO
// ============================================================

await authDataSource.deleteCurrentUser();

final member = await registerUser.call(
name: 'Membro do Projeto',
email: 'member.$timestamp@agileacademical.com',
password: 'Teste@123456',
role: UserRole.student,
);

expect(member.uid, isNotEmpty);

expect(
member.uid,
isNot(equals(owner.uid)),
);

// ============================================================
// CREATE PROJECT
// ============================================================

final project = Project(
id: '',
title: 'Projeto de Membros',
description: 'Projeto criado para testar membros.',
status: ProjectStatus.planning,
ownerId: owner.uid,
advisorId: null,
memberIds: [owner.uid],
createdAt: DateTime.now(),
updatedAt: DateTime.now(),
);

final projectId = await projectRepository.createProject(
project,
);

expect(projectId, isNotEmpty);

// ============================================================
// READ INICIAL
// ============================================================

final initialProject =
await projectRepository.getProject(projectId);

expect(initialProject, isNotNull);

expect(
initialProject!.memberIds,
contains(owner.uid),
);

expect(
initialProject.memberIds,
isNot(contains(member.uid)),
);

// ============================================================
// ADD MEMBER
// ============================================================

await projectRepository.addMember(
projectId,
member.uid,
);

final projectAfterAdd =
await projectRepository.getProject(projectId);

expect(projectAfterAdd, isNotNull);

expect(
projectAfterAdd!.memberIds,
contains(owner.uid),
);

expect(
projectAfterAdd.memberIds,
contains(member.uid),
);

// ============================================================
// GET PROJECTS FOR MEMBER
// ============================================================

final memberProjects =
await projectRepository.getProjectsForUser(
member.uid,
);

expect(
memberProjects.any(
(project) => project.id == projectId,
),
isTrue,
);

// ============================================================
// REMOVE MEMBER
// ============================================================

await projectRepository.removeMember(
projectId,
member.uid,
);

final projectAfterRemove =
await projectRepository.getProject(projectId);

expect(projectAfterRemove, isNotNull);

expect(
projectAfterRemove!.memberIds,
contains(owner.uid),
);

expect(
projectAfterRemove.memberIds,
isNot(contains(member.uid)),
);

// ============================================================
// MEMBER NÃO DEVE MAIS ENCONTRAR O PROJETO
// ============================================================

final memberProjectsAfterRemove =
await projectRepository.getProjectsForUser(
member.uid,
);

expect(
memberProjectsAfterRemove.any(
(project) => project.id == projectId,
),
isFalse,
);

// ============================================================
// CLEANUP - DELETE PROJECT
// ============================================================

await projectRepository.deleteProject(projectId);

final deletedProject =
await projectRepository.getProject(projectId);

expect(
deletedProject,
isNull,
);

// ============================================================
// CLEANUP - DELETE MEMBER AUTHENTICATION
// ============================================================

await authDataSource.deleteCurrentUser();

expect(
authDataSource.currentUser,
isNull,
);

// ============================================================
// CLEANUP - OWNER
//
// O owner foi criado antes do member e não está mais
// autenticado. O teste pode deixar o documento Firestore
// correspondente para a etapa atual.
// ============================================================
},
);
}

