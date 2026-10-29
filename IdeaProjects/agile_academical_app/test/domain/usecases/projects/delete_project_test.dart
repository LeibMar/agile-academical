
import 'package:flutter_test/flutter_test.dart';
import 'package:agile_academical_app/domain/entities/project.dart';
import 'package:agile_academical_app/domain/repositories/project_repository.dart';
import 'package:agile_academical_app/domain/usecases/projects/delete_project.dart';

class FakeProjectRepository implements ProjectRepository {
  String? receivedProjectId;

  @override
  Future<String> createProject(Project project) async => 'project-1';

  @override
  Future<Project?> getProject(String projectId) async => null;

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
  Future<void> deleteProject(String projectId) async {
    receivedProjectId = projectId;
  }
}

void main() {
  late FakeProjectRepository repository;
  late DeleteProject deleteProject;

  setUp(() {
    repository = FakeProjectRepository();
    deleteProject = DeleteProject(repository);
  });

  test('exclui projeto com ID normalizado', () async {
    await deleteProject(' project-1 ');

    expect(repository.receivedProjectId, 'project-1');
  });

  test('rejeita ID de projeto vazio', () {
    expect(
          () => deleteProject('   '),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedProjectId, isNull);
  });
}
