
import 'package:flutter_test/flutter_test.dart';
import 'package:agile_academical_app/domain/entities/project.dart';
import 'package:agile_academical_app/domain/repositories/project_repository.dart';
import 'package:agile_academical_app/domain/usecases/projects/cancel_project.dart';

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
  Future<void> cancelProject(String projectId) async {
    receivedProjectId = projectId;
  }

  @override
  Future<void> deleteProject(String projectId) async {}
}

void main() {
  late FakeProjectRepository repository;
  late CancelProject cancelProject;

  setUp(() {
    repository = FakeProjectRepository();
    cancelProject = CancelProject(repository);
  });

  test('cancela projeto com ID normalizado', () async {
    await cancelProject(' project-1 ');

    expect(repository.receivedProjectId, 'project-1');
  });

  test('rejeita ID de projeto vazio', () {
    expect(
          () => cancelProject('   '),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedProjectId, isNull);
  });
}
