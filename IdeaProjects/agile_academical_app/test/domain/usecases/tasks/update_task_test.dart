
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/task.dart';
import 'package:agile_academical_app/domain/repositories/task_repository.dart';
import 'package:agile_academical_app/domain/usecases/tasks/update_task.dart';

class FakeTaskRepository implements TaskRepository {
Task? updatedTask;

@override
Future<void> updateTask(Task task) async {
updatedTask = task;
}

@override
dynamic noSuchMethod(Invocation invocation) {
return super.noSuchMethod(invocation);
}
}

void main() {
late FakeTaskRepository repository;
late UpdateTask updateTask;

setUp(() {
repository = FakeTaskRepository();
updateTask = UpdateTask(repository);
});

test('deve encaminhar a tarefa ao repositório para atualização', () async {
// Arrange
//final now = DateTime(2026, 10, 14, 10, 0);

final task = Task(
id: 'task-001',
projectId: 'project-001',
stageId: 'stage-001',
title: 'Revisar documentação',
description: 'Revisar a documentação do projeto',
status: TaskStatus.inReview,
priority: TaskPriority.high,
assignedTo: 'user-001',
createdBy: 'user-002',
startDate: null,
dueDate: null,
completedAt: null,
createdAt: DateTime(2026, 10, 10),
updatedAt: DateTime(2026, 10, 14),
);

// Act
await updateTask(task);

// Assert
expect(repository.updatedTask, isNotNull);
expect(repository.updatedTask!.id, task.id);
expect(repository.updatedTask!.projectId, task.projectId);
expect(repository.updatedTask!.title, task.title);
expect(repository.updatedTask!.status, TaskStatus.inReview);
expect(repository.updatedTask!.priority, TaskPriority.high);
expect(repository.updatedTask, same(task));
});
}
