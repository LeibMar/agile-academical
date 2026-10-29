
import 'package:flutter_test/flutter_test.dart';
import 'package:agile_academical_app/domain/entities/project.dart';
import 'package:agile_academical_app/domain/repositories/project_repository.dart';
import 'package:agile_academical_app/domain/usecases/projects/update_project.dart';

class FakeProjectRepository implements ProjectRepository {
  Project? receivedProject;

  @override
  Future<String> createProject(Project project) async => 'project-1';

  @override
  Future<Project?> getProject(String projectId) async => null;

  @override
  Future<List<Project>> getProjectsForUser(String userId) async => [];

  @override
  Future<void> updateProject(Project project) async {
    receivedProject = project;
  }

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
  String title = 'TCC de ADS',
  String ownerId = 'user-1',
  String? description = 'Projeto original',
  String? advisorId = 'advisor-1',
  List<String> memberIds = const ['user-1', 'user-2'],
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime(2026, 10, 13, 10);

  return Project(
    id: 'project-1',
    title: title,
    description: description,
    status: ProjectStatus.planning,
    ownerId: ownerId,
    advisorId: advisorId,
    memberIds: memberIds,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  late FakeProjectRepository repository;
  late UpdateProject updateProject;

  setUp(() {
    repository = FakeProjectRepository();
    updateProject = UpdateProject(repository);
  });

  test('atualiza o projeto com dados normalizados', () async {
    final createdAt = DateTime(2026, 10, 1);
    final current = makeProject(createdAt: createdAt);

    final updated = makeProject(
      title: '  Novo título do TCC  ',
      description: '  Nova descrição  ',
      advisorId: ' advisor-2 ',
      memberIds: const ['user-2', 'user-3'],
    );

    await updateProject(current, updated);

    final result = repository.receivedProject!;

    expect(result.id, current.id);
    expect(result.title, 'Novo título do TCC');
    expect(result.description, 'Nova descrição');
    expect(result.ownerId, current.ownerId);
    expect(result.advisorId, 'advisor-2');
    expect(result.memberIds, contains('user-1'));
    expect(result.memberIds, contains('user-3'));
    expect(result.createdAt, createdAt);
    expect(result.updatedAt.isAfter(current.updatedAt), isTrue);
  });

  test('rejeita alteração do ID do projeto', () {
    final current = makeProject();
    final updated = Project(
      id: 'project-2',
      title: 'Novo título',
      description: current.description,
      status: current.status,
      ownerId: current.ownerId,
      advisorId: current.advisorId,
      memberIds: current.memberIds,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );

    expect(
          () => updateProject(current, updated),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedProject, isNull);
  });

  test('rejeita alteração do proprietário do projeto', () {
    final current = makeProject();
    final updated = makeProject(ownerId: 'user-2');

    expect(
          () => updateProject(current, updated),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedProject, isNull);
  });

  test('rejeita título vazio', () {
    final current = makeProject();
    final updated = makeProject(title: '   ');

    expect(
          () => updateProject(current, updated),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.receivedProject, isNull);
  });
}
