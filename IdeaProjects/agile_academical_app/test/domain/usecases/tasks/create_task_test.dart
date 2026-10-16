
import 'package:flutter_test/flutter_test.dart';
import 'package:agile_academical_app/domain/entities/task.dart';
import 'package:agile_academical_app/domain/repositories/task_repository.dart';
import 'package:agile_academical_app/domain/usecases/tasks/create_task.dart';

class FakeTaskRepository implements TaskRepository {
  Task? receivedTask;

  @override
  Future<String> createTask(Task task) async {
    receivedTask = task;
    return 'task-generated-id';
  }

  @override
  Future<Task?> getTask(String projectId, String taskId) async => null;

  @override
  Future<List<Task>> getTasksForProject(String projectId) async => [];

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<void> deleteTask(String projectId, String taskId) async {}
}

Task makeTask({
  String title = '  Revisar referencial teórico  ',
  String projectId = 'project-1',
  String createdBy = 'user-1',
  String? stageId,
  String? assignedTo,
  DateTime? startDate,
  DateTime? dueDate,
}) {
  final now = DateTime(2026, 10, 13, 10);

  return Task(
    id: '',
    projectId: projectId,
    stageId: stageId,
    title: title,
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    assignedTo: assignedTo,
    createdBy: createdBy,
    startDate: startDate,
    dueDate: dueDate,
    createdAt: now,
    updatedAt: now,

  );
}

void main() {
  late FakeTaskRepository repository;
  late CreateTask createTask;

  setUp(() {
    repository = FakeTaskRepository();
    createTask = CreateTask(taskRepository: repository);
  });

  test('cria tarefa com dados normalizados e retorna o ID', () async {
    final task = makeTask();

    final id = await createTask(task);

    expect(id, 'task-generated-id');
    expect(repository.receivedTask, isNotNull);
    expect(repository.receivedTask!.title, 'Revisar referencial teórico');
    expect(repository.receivedTask!.projectId, 'project-1');
    expect(repository.receivedTask!.createdBy, 'user-1');
    expect(repository.receivedTask!.createdAt, isNot(task.createdAt));
    expect(
      repository.receivedTask!.createdAt,
      repository.receivedTask!.updatedAt,
    );
  });

  test('não persiste tarefa com título vazio', () async {
    final task = makeTask(title: '   ');

    await expectLater(
      createTask(task),
      throwsArgumentError,
    );

    expect(repository.receivedTask, isNull);
  });
  test('não persiste tarefa sem projeto', () async {
    final task = makeTask(projectId: '');

    await expectLater(
      createTask(task),
      throwsArgumentError,
    );

    expect(repository.receivedTask, isNull);
  });
  test('não persiste tarefa sem criador', () async {
    final task = makeTask(createdBy: '');

    await expectLater(
      createTask(task),
      throwsArgumentError,
    );

    expect(repository.receivedTask, isNull);
  });
  test('não persiste tarefa com ID de etapa vazio', () async {
    final task = makeTask(stageId: '');

    await expectLater(
      createTask(task),
      throwsArgumentError,
    );

    expect(repository.receivedTask, isNull);
  });
  test('não persiste tarefa com responsável vazio', () async {
    final task = makeTask(assignedTo: '');

    await expectLater(
      createTask(task),
      throwsArgumentError,
    );

    expect(repository.receivedTask, isNull);
  });

  test('não persiste tarefa com vencimento anterior ao início', () async {
    final task = makeTask(
      startDate: DateTime(2026, 10, 14),
      dueDate: DateTime(2026, 10, 13),
    );

    await expectLater(
      createTask(task),
      throwsArgumentError,
    );

    expect(repository.receivedTask, isNull);
  });
  test('persiste tarefa com vencimento igual ao início', () async {
    final data = DateTime(2026, 10, 14);

    final task = makeTask(
      startDate: data,
      dueDate: data,
    );

    final id = await createTask(task);

    expect(id, 'task-generated-id');
    expect(repository.receivedTask, isNotNull);
    expect(repository.receivedTask!.startDate, data);
    expect(repository.receivedTask!.dueDate, data);
  });
}
