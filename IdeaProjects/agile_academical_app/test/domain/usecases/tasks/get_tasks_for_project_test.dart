
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/task.dart';
import 'package:agile_academical_app/domain/repositories/task_repository.dart';
import 'package:agile_academical_app/domain/usecases/tasks/get_tasks_for_project.dart';

class FakeTaskRepository implements TaskRepository {
  List<Task> tasksToReturn = [];
  String? receivedProjectId;

  @override
  Future<List<Task>> getTasksForProject(String projectId) async {
    receivedProjectId = projectId;
    return tasksToReturn;
  }

  @override
  Future<String> createTask(Task task) async {
    throw UnimplementedError();
  }

  @override
  Future<Task?> getTask(String projectId, String taskId) async {
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
  group('GetTasksForProject', () {
    late FakeTaskRepository repository;
    late GetTasksForProject getTasksForProject;

    setUp(() {
      repository = FakeTaskRepository();
      getTasksForProject = GetTasksForProject(repository);
    });

    test('deve retornar uma lista vazia quando o projeto não tiver tarefas',
            () async {
          final result = await getTasksForProject('project-1');

          expect(result, isEmpty);
          expect(repository.receivedProjectId, 'project-1');
        });

    test('deve retornar a lista de tarefas do projeto', () async {
      final now = DateTime.now();

      final task1 = Task(
        id: 'task-1',
        projectId: 'project-1',
        title: 'Definir requisitos',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        createdBy: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      final task2 = Task(
        id: 'task-2',
        projectId: 'project-1',
        title: 'Implementar funcionalidades',
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        createdBy: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      repository.tasksToReturn = [task1, task2];

      final result = await getTasksForProject('project-1');

      expect(result, hasLength(2));
      expect(result, equals([task1, task2]));
      expect(repository.receivedProjectId, 'project-1');
    });
  });
}
