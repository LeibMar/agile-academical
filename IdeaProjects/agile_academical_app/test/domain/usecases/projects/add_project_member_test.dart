
import 'package:flutter_test/flutter_test.dart';
import 'package:agile_academical_app/domain/entities/project.dart';
import 'package:agile_academical_app/domain/repositories/project_repository.dart';
import 'package:agile_academical_app/domain/usecases/projects/add_project_member.dart';

class FakeProjectRepository implements ProjectRepository {
  String? receivedProjectId;
  String? receivedUserId;

  @override
  Future<String> createProject(Project project) async => 'project-1';

  @override
  Future<Project?> getProject(String projectId) async => null;

  @override
  Future<List<Project>> getProjectsForUser(String userId) async => [];

  @override
  Future<void> updateProject(Project project) async {}

  @override
  Future<void> addMember(String projectId, String userId) async {
    receivedProjectId = projectId;
    receivedUserId = userId;
  }

  @override
  Future<void> removeMember(String projectId, String userId) async {}

  @override
  Future<void> cancelProject(String projectId) async {}

  @override
  Future<void> deleteProject(String projectId) async {}
}

void main() {
  late FakeProjectRepository repository;
  late AddProjectMember addProjectMember;

  setUp(() {
    repository = FakeProjectRepository();
    addProjectMember = AddProjectMember(repository);
  });

  test('adiciona membro com IDs normalizados', () async {
    await addProjectMember.call(
      projectId: ' project-1 ',
      userId: ' user-2 ',
    );

    expect(repository.receivedProjectId, 'project-1');
    expect(repository.receivedUserId, 'user-2');
  });

  test('rejeita ID de projeto vazio', () {
    expect(
          () => addProjectMember.call(
        projectId: '   ',
        userId: 'user-2',
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedProjectId, isNull);
  });

  test('rejeita ID de usuário vazio', () {
    expect(
          () => addProjectMember.call(
        projectId: 'project-1',
        userId: '   ',
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedProjectId, isNull);
  });
}
