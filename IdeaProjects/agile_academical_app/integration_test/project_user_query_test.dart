
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
'deve retornar projetos para owner e membro, mas não para usuário externo',
(WidgetTester tester) async {
final timestamp = DateTime.now().millisecondsSinceEpoch;

// ============================================================
// PREPARAÇÃO - OWNER
// ============================================================

final owner = await registerUser.call(
name: 'Owner do Projeto',
email: 'query.owner.$timestamp@agileacademical.com',
password: 'Teste@123456',
role: UserRole.student,
);

expect(owner.uid, isNotEmpty);

// ============================================================
// PREPARAÇÃO - MEMBER
// ============================================================

await authDataSource.deleteCurrentUser();

final member = await registerUser.call(
name: 'Membro do Projeto',
email: 'query.member.$timestamp@agileacademical.com',
password: 'Teste@123456',
role: UserRole.student,
);

expect(member.uid, isNotEmpty);

expect(
member.uid,
isNot(equals(owner.uid)),
);

// ============================================================
// PREPARAÇÃO - USUÁRIO EXTERNO
// ============================================================

await authDataSource.deleteCurrentUser();

final externalUser = await registerUser.call(
name: 'Usuário Externo',
email: 'query.external.$timestamp@agileacademical.com',
password: 'Teste@123456',
role: UserRole.student,
);

expect(externalUser.uid, isNotEmpty);

expect(
externalUser.uid,
isNot(equals(owner.uid)),
);

expect(
externalUser.uid,
isNot(equals(member.uid)),
);

// ============================================================
// CREATE PROJECT
// ============================================================

final project = Project(
id: '',
title: 'Projeto de Consulta',
description: 'Projeto criado para testar getProjectsForUser.',
status: ProjectStatus.planning,
ownerId: owner.uid,
advisorId: null,
memberIds: [
owner.uid,
member.uid,
],
createdAt: DateTime.now(),
updatedAt: DateTime.now(),
);

final projectId = await projectRepository.createProject(
project,
);

expect(projectId, isNotEmpty);

// ============================================================
// OWNER DEVE ENCONTRAR O PROJETO
// ============================================================

final ownerProjects =
await projectRepository.getProjectsForUser(
owner.uid,
);

expect(
ownerProjects.any(
(project) => project.id == projectId,
),
isTrue,
);

// ============================================================
// MEMBER DEVE ENCONTRAR O PROJETO
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
// USUÁRIO EXTERNO NÃO DEVE ENCONTRAR O PROJETO
// ============================================================

final externalUserProjects =
await projectRepository.getProjectsForUser(
externalUser.uid,
);

expect(
externalUserProjects.any(
(project) => project.id == projectId,
),
isFalse,
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

