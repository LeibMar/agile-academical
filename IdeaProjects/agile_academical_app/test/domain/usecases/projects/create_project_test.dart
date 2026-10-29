
import 'package:flutter_test/flutter_test.dart';
import 'package:agile_academical_app/domain/entities/project.dart';
import 'package:agile_academical_app/domain/repositories/project_repository.dart';
import 'package:agile_academical_app/domain/usecases/projects/create_project.dart';

class FakeProjectRepository implements ProjectRepository {
  Project? receivedProject;

  @override
  Future<String> createProject(Project project) async {
    receivedProject = project;
    return 'project-generated-id';
  }

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
  Future<void> deleteProject(String projectId) async {}
}

Project makeProject({
  String title = '  TCC de ADS  ',
  String ownerId = 'user-1',
  String? description = '  Projeto de conclusão de curso  ',
  String? advisorId = 'advisor-1',
  List<String> memberIds = const ['user-2', 'user-1', 'user-2'],
}) {
  final now = DateTime(2026, 10, 13, 10);

  return Project(
    id: '',
    title: title,
    description: description,
    status: ProjectStatus.planning,
    ownerId: ownerId,
    advisorId: advisorId,
    memberIds: memberIds,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late FakeProjectRepository repository;
  late CreateProject createProject;

  setUp(() {
    repository = FakeProjectRepository();
    createProject = CreateProject(repository);
  });

  test('cria projeto com dados normalizados e retorna o ID', () async {
    final project = makeProject();

    final id = await createProject(project);

    expect(id, 'project-generated-id');
    expect(repository.receivedProject, isNotNull);
    expect(repository.receivedProject!.title, 'TCC de ADS');
    expect(
      repository.receivedProject!.description,
      'Projeto de conclusão de curso',
    );
    expect(repository.receivedProject!.ownerId, 'user-1');
    expect(repository.receivedProject!.advisorId, 'advisor-1');
    expect(
      repository.receivedProject!.memberIds.toSet(),
      {'user-1', 'user-2'},
    );
    expect(repository.receivedProject!.memberIds, contains('user-1'));
    expect(repository.receivedProject!.createdAt, isNot(project.createdAt));
    expect(
      repository.receivedProject!.createdAt,
      repository.receivedProject!.updatedAt,
    );
  });

  test('não persiste projeto com título vazio', () async {
    final project = makeProject(title: '   ');

    await expectLater(
      createProject(project),
      throwsArgumentError,
    );

    expect(repository.receivedProject, isNull);
  });

  test('não persiste projeto sem proprietário', () async {
    final project = makeProject(ownerId: '');

    await expectLater(
      createProject(project),
      throwsArgumentError,
    );

    expect(repository.receivedProject, isNull);
  });

  test('não persiste projeto com ID de membro vazio', () async {
    final project = makeProject(memberIds: ['user-1', '  ']);

    await expectLater(
      createProject(project),
      throwsArgumentError,
    );

    expect(repository.receivedProject, isNull);
  });

  test('não persiste projeto com ID de orientador vazio', () async {
    final project = makeProject(advisorId: '   ');

    await expectLater(
      createProject(project),
      throwsArgumentError,
    );

    expect(repository.receivedProject, isNull);
  });

  test('normaliza descrição vazia para null', () async {
    final project = makeProject(description: '   ');

    await createProject(project);

    expect(repository.receivedProject, isNotNull);
    expect(repository.receivedProject!.description, isNull);
  });
}
