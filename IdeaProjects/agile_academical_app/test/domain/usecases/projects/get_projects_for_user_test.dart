
import 'package:flutter_test/flutter_test.dart';
import 'package:agile_academical_app/domain/entities/project.dart';
import 'package:agile_academical_app/domain/repositories/project_repository.dart';
import 'package:agile_academical_app/domain/usecases/projects/get_projects_for_user.dart';

class FakeProjectRepository implements ProjectRepository {
  String? receivedUserId;
  List<Project> projectsToReturn = [];

  @override
  Future<String> createProject(Project project) async => 'project-1';

  @override
  Future<Project?> getProject(String projectId) async => null;

  @override
  Future<List<Project>> getProjectsForUser(String userId) async {
    receivedUserId = userId;
    return projectsToReturn;
  }

  @override
  Future<void> updateProject(Project project) async {}

  @override
  Future<void> addMember(String projectId, String userId) async {}

  @override
  Future<void> removeMember(String projectId, String userId) async {}

  @override
  Future<void> cancelProject(String projectId) async {}

  @override
  Future<void> deleteProject(String projectId) async {}
}

Project makeProject({
  required String id,
  required String title,
}) {
  final now = DateTime(2026, 10, 13, 10);

  return Project(
    id: id,
    title: title,
    status: ProjectStatus.planning,
    ownerId: 'user-1',
    memberIds: const ['user-1', 'user-2'],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late FakeProjectRepository repository;
  late GetProjectsForUser getProjectsForUser;

  setUp(() {
    repository = FakeProjectRepository();
    getProjectsForUser = GetProjectsForUser(repository);
  });

  test('recupera os projetos do usuário pelo ID normalizado', () async {
    final projects = [
      makeProject(id: 'project-1', title: 'TCC de ADS'),
      makeProject(id: 'project-2', title: 'Projeto de Pesquisa'),
    ];

    repository.projectsToReturn = projects;

    final result = await getProjectsForUser('  user-1  ');

    expect(result, projects);
    expect(repository.receivedUserId, 'user-1');
  });

  test('retorna lista vazia quando o usuário não possui projetos', () async {
    final result = await getProjectsForUser('user-1');

    expect(result, isEmpty);
    expect(repository.receivedUserId, 'user-1');
  });

  test('rejeita um ID de usuário vazio', () {
    expect(
          () => getProjectsForUser('   '),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedUserId, isNull);
  });
}
