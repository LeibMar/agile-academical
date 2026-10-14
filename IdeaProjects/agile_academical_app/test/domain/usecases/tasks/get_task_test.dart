
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/task.dart';
import 'package:agile_academical_app/domain/repositories/task_repository.dart';
import 'package:agile_academical_app/domain/usecases/tasks/get_task.dart';

class FakeTaskRepository implements TaskRepository {
  Task? taskToReturn;
  String? receivedProjectId;
  String? receivedTaskId;

  @override
  Future<Task?> getTask(String projectId, String taskId) async {
    receivedProjectId = projectId;
    receivedTaskId = taskId;
    return taskToReturn;
  }

  @override
  Future<String> createTask(Task task) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasksForProject(String projectId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(Task task) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String projectId, String taskId) async {
    throw UnimplementedError();
  }
}

void main() {
  group('GetTask', () {
    late FakeTaskRepository repository;
    late GetTask getTask;

    setUp(() {
      repository = FakeTaskRepository();
      getTask = GetTask(repository);
    });

    test('deve retornar null quando a tarefa não existir', () async {
      final result = await getTask('project-1', 'task-1');

      expect(result, isNull);
      expect(repository.receivedProjectId, 'project-1');
      expect(repository.receivedTaskId, 'task-1');
    });

    test('deve retornar a tarefa quando ela existir', () async {
      final now = DateTime.now();

      final task = Task(
        id: 'task-1',
        projectId: 'project-1',
        title: 'Implementar tela de tarefas',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        createdBy: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      repository.taskToReturn = task;

      final result = await getTask('project-1', 'task-1');

      expect(result, isNotNull);
      expect(result, same(task));
      expect(result!.id, 'task-1');
      expect(result.projectId, 'project-1');
      expect(repository.receivedProjectId, 'project-1');
      expect(repository.receivedTaskId, 'task-1');
    });

  });


}
