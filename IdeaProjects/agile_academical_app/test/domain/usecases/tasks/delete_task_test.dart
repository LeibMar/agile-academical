
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/task.dart';
import 'package:agile_academical_app/domain/repositories/task_repository.dart';
import 'package:agile_academical_app/domain/usecases/tasks/delete_task.dart';

class FakeTaskRepository implements TaskRepository {
  String? receivedProjectId;
  String? receivedTaskId;
  bool deleteCalled = false;

  @override
  Future<void> deleteTask(String projectId, String taskId) async {
    receivedProjectId = projectId;
    receivedTaskId = taskId;
    deleteCalled = true;
  }

  @override
  Future<String> createTask(Task task) async =>
      throw UnimplementedError();

  @override
  Future<Task?> getTask(String projectId, String taskId) async =>
      throw UnimplementedError();

  @override
  Future<List<Task>> getTasksForProject(String projectId) async =>
      throw UnimplementedError();

  @override
  Future<void> updateTask(Task task) async =>
      throw UnimplementedError();
}

void main() {
  group('DeleteTask', () {
    late FakeTaskRepository repository;
    late DeleteTask deleteTask;

    setUp(() {
      repository = FakeTaskRepository();
      deleteTask = DeleteTask(repository);
    });

    test('deve solicitar a exclusão da tarefa correta', () async {
      await deleteTask('project-1', 'task-1');

      expect(repository.deleteCalled, isTrue);
      expect(repository.receivedProjectId, 'project-1');
      expect(repository.receivedTaskId, 'task-1');
    });
  });
}
