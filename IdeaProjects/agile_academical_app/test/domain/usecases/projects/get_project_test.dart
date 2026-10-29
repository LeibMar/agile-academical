
import 'package:flutter_test/flutter_test.dart';
import 'package:agile_academical_app/domain/entities/project.dart';
import 'package:agile_academical_app/domain/repositories/project_repository.dart';
import 'package:agile_academical_app/domain/usecases/projects/get_project.dart';

class FakeProjectRepository implements ProjectRepository {
  String? receivedProjectId;
  Project? projectToReturn;

  @override
  Future<String> createProject(Project project) async => 'project-1';

  @override
  Future<Project?> getProject(String projectId) async {
    receivedProjectId = projectId;
    return projectToReturn;
  }

  @override
  Future<List<Project>> getProjectsForUser(String userId) async => [];

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

Project makeProject() {
  final now = DateTime(2026, 10, 13, 10);

  return Project(
    id: 'project-1',
    title: 'TCC de ADS',
    description: 'Projeto de conclusão de curso',
    status: ProjectStatus.planning,
    ownerId: 'user-1',
    advisorId: 'advisor-1',
    memberIds: const ['user-1', 'user-2'],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late FakeProjectRepository repository;
  late GetProject getProject;

  setUp(() {
    repository = FakeProjectRepository();
    getProject = GetProject(repository);
  });

  test('recupera o projeto pelo ID normalizado', () async {
    final project = makeProject();
    repository.projectToReturn = project;

    final result = await getProject('  project-1  ');

    expect(result, same(project));
    expect(repository.receivedProjectId, 'project-1');
  });

  test('retorna null quando o projeto não é encontrado', () async {
    final result = await getProject('project-inexistente');

    expect(result, isNull);
    expect(repository.receivedProjectId, 'project-inexistente');
  });


  test('rejeita um ID vazio', () {
    expect(
          () => getProject('   '),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedProjectId, isNull);
  });

}
