
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/task.dart';
import 'package:agile_academical_app/domain/usecases/tasks/task_rules.dart';

void main() {
final now = DateTime(2026, 10, 13, 10);

Task makeTask({
String id = '',
String projectId = 'project-1',
String title = 'Implementar funcionalidade',
String createdBy = 'user-1',
TaskStatus status = TaskStatus.todo,
DateTime? startDate,
DateTime? dueDate,
DateTime? completedAt,
DateTime? createdAt,
DateTime? updatedAt,
}) {
return Task(
id: id,
projectId: projectId,
title: title,
status: status,
priority: TaskPriority.medium,
createdBy: createdBy,
startDate: startDate,
dueDate: dueDate,
completedAt: completedAt,
createdAt: createdAt ?? now,
updatedAt: updatedAt ?? now,
);
}

group('TaskRules.prepareForCreation', () {
test('deve preparar uma tarefa nova corretamente', () {
final result = TaskRules.prepareForCreation(
makeTask(title: '  Implementar funcionalidade  '),
now: now,
);

expect(result.title, 'Implementar funcionalidade');
expect(result.createdAt, now);
expect(result.updatedAt, now);
expect(result.completedAt, isNull);
});

test('deve definir a conclusão ao criar tarefa em done', () {
final result = TaskRules.prepareForCreation(
makeTask(status: TaskStatus.done),
now: now,
);

expect(result.completedAt, now);
});

test('deve rejeitar título vazio', () {
expect(
() => TaskRules.prepareForCreation(
makeTask(title: '   '),
now: now,
),
throwsArgumentError,
);
});

test('deve rejeitar entrega anterior ao início', () {
expect(
() => TaskRules.prepareForCreation(
makeTask(
startDate: DateTime(2026, 10, 20),
dueDate: DateTime(2026, 10, 19),
),
now: now,
),
throwsArgumentError,
);
});

test('deve rejeitar tarefa sem projeto', () {
expect(
() => TaskRules.prepareForCreation(
makeTask(projectId: ''),
now: now,
),
throwsArgumentError,
);
});
test('deve rejeitar tarefa sem criador', () {
  expect(
        () => TaskRules.prepareForCreation(
      makeTask(createdBy: ''),
      now: now,
    ),
    throwsArgumentError,
  );
});

test('deve rejeitar ID de etapa vazio quando informado', () {
  expect(
        () => TaskRules.prepareForCreation(
      Task(
        id: '',
        projectId: 'project-1',
        stageId: '',
        title: 'Implementar funcionalidade',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        createdBy: 'user-1',
        createdAt: now,
        updatedAt: now,
      ),
      now: now,
    ),
    throwsArgumentError,
  );
});

test('deve rejeitar responsável vazio quando informado', () {
  expect(
        () => TaskRules.prepareForCreation(
      Task(
        id: '',
        projectId: 'project-1',
        title: 'Implementar funcionalidade',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        assignedTo: '',
        createdBy: 'user-1',
        createdAt: now,
        updatedAt: now,
      ),
      now: now,
    ),
    throwsArgumentError,
  );
});
});

group('TaskRules.prepareForUpdate', () {
test('deve preservar criador e data de criação', () {
final originalDate = DateTime(2026, 10, 1);

final current = makeTask(
id: 'task-1',
createdBy: 'original-user',
createdAt: originalDate,
);

final updated = makeTask(
id: 'task-1',
createdBy: 'another-user',
createdAt: now,
title: 'Título atualizado',
);

final result = TaskRules.prepareForUpdate(
current,
updated,
now: now,
);

expect(result.createdBy, 'original-user');
expect(result.createdAt, originalDate);
expect(result.updatedAt, now);
expect(result.title, 'Título atualizado');
});

test('deve definir completedAt ao concluir a tarefa', () {
final current = makeTask(
id: 'task-1',
status: TaskStatus.inProgress,
);

final updated = makeTask(
id: 'task-1',
status: TaskStatus.done,
);

final result = TaskRules.prepareForUpdate(
current,
updated,
now: now,
);

expect(result.completedAt, now);
});

test('deve preservar completedAt enquanto continuar concluída', () {
final completionDate = DateTime(2026, 10, 10);

final current = makeTask(
id: 'task-1',
status: TaskStatus.done,
completedAt: completionDate,
);

final updated = makeTask(
id: 'task-1',
status: TaskStatus.done,
completedAt: now,
);

final result = TaskRules.prepareForUpdate(
current,
updated,
now: now,
);

expect(result.completedAt, completionDate);
});

test('deve limpar completedAt ao reabrir a tarefa', () {
final current = makeTask(
id: 'task-1',
status: TaskStatus.done,
completedAt: DateTime(2026, 10, 10),
);

final updated = makeTask(
id: 'task-1',
status: TaskStatus.inProgress,
);

final result = TaskRules.prepareForUpdate(
current,
updated,
now: now,
);

expect(result.completedAt, isNull);
});

test('deve rejeitar alteração do ID', () {
final current = makeTask(id: 'task-1');
final updated = makeTask(id: 'task-2');

expect(
() => TaskRules.prepareForUpdate(
current,
updated,
now: now,
),
throwsArgumentError,
);
});

test('deve rejeitar alteração do projeto', () {
final current = makeTask(id: 'task-1');
final updated = makeTask(
id: 'task-1',
projectId: 'project-2',
);

expect(
() => TaskRules.prepareForUpdate(
current,
updated,
now: now,
),
throwsArgumentError,
);
});

test('deve rejeitar entrega anterior ao início', () {
  final current = makeTask(id: 'task-1');

  final updated = makeTask(
    id: 'task-1',
    startDate: DateTime(2026, 10, 20),
    dueDate: DateTime(2026, 10, 19),
  );

  expect(
        () => TaskRules.prepareForUpdate(
      current,
      updated,
      now: now,
    ),
    throwsArgumentError,
  );
});
test('deve remover espaços do título ao atualizar', () {
  final current = makeTask(id: 'task-1');

  final updated = makeTask(
    id: 'task-1',
    title: '  Título atualizado  ',
  );

  final result = TaskRules.prepareForUpdate(
    current,
    updated,
    now: now,
  );

  expect(result.title, 'Título atualizado');
});

test('deve preservar completedAt quando a atualização não informar a data', () {
  final completionDate = DateTime(2026, 10, 10);

  final current = makeTask(
    id: 'task-1',
    status: TaskStatus.done,
    completedAt: completionDate,
  );

  final updated = makeTask(
    id: 'task-1',
    status: TaskStatus.done,
    completedAt: null,
  );

  final result = TaskRules.prepareForUpdate(
    current,
    updated,
    now: now,
  );

  expect(result.completedAt, completionDate);
});
});
}
