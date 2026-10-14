
import '../../entities/task.dart';

class TaskRules {
/// Prepara uma tarefa nova antes de enviá-la ao repositório.
static Task prepareForCreation(
Task task, {
DateTime? now,
}) {
_validate(task);

final timestamp = now ?? DateTime.now();

return Task(
id: task.id,
projectId: task.projectId,
stageId: task.stageId,
title: task.title.trim(),
description: task.description,
status: task.status,
priority: task.priority,
assignedTo: task.assignedTo,
createdBy: task.createdBy,
startDate: task.startDate,
dueDate: task.dueDate,
completedAt: task.status == TaskStatus.done
? task.completedAt ?? timestamp
    : null,
createdAt: timestamp,
updatedAt: timestamp,
);
}

/// Prepara uma tarefa atualizada, preservando os dados imutáveis.
static Task prepareForUpdate(
Task current,
Task updated, {
DateTime? now,
}) {
if (current.id != updated.id) {
throw ArgumentError(
'O ID da tarefa não pode ser alterado.',
);
}

if (current.projectId != updated.projectId) {
throw ArgumentError(
'A tarefa não pode ser transferida para outro projeto '
'por meio de uma atualização.',
);
}

final normalized = Task(
id: current.id,
projectId: current.projectId,
stageId: updated.stageId,
title: updated.title,
description: updated.description,
status: updated.status,
priority: updated.priority,
assignedTo: updated.assignedTo,
createdBy: current.createdBy,
startDate: updated.startDate,
dueDate: updated.dueDate,
completedAt: updated.completedAt,
createdAt: current.createdAt,
updatedAt: updated.updatedAt,
);

_validate(normalized);

final timestamp = now ?? DateTime.now();

DateTime? completedAt;

if (normalized.status == TaskStatus.done) {
if (current.status == TaskStatus.done) {
completedAt =
current.completedAt ?? normalized.completedAt ?? timestamp;
} else {
completedAt = normalized.completedAt ?? timestamp;
}
}

return Task(
id: normalized.id,
projectId: normalized.projectId,
stageId: normalized.stageId,
title: normalized.title.trim(),
description: normalized.description,
status: normalized.status,
priority: normalized.priority,
assignedTo: normalized.assignedTo,
createdBy: normalized.createdBy,
startDate: normalized.startDate,
dueDate: normalized.dueDate,
completedAt: completedAt,
createdAt: current.createdAt,
updatedAt: timestamp,
);
}

static void _validate(Task task) {
if (task.projectId.trim().isEmpty) {
throw ArgumentError(
'A tarefa deve estar associada a um projeto.',
);
}

if (task.title.trim().isEmpty) {
throw ArgumentError(
'O título da tarefa não pode ser vazio.',
);
}

if (task.createdBy.trim().isEmpty) {
throw ArgumentError(
'A tarefa deve possuir um criador.',
);
}

if (task.stageId != null && task.stageId!.trim().isEmpty) {
throw ArgumentError(
'O ID da etapa não pode ser vazio.',
);
}

if (task.assignedTo != null &&
task.assignedTo!.trim().isEmpty) {
throw ArgumentError(
'O ID do responsável não pode ser vazio.',
);
}

if (task.startDate != null &&
task.dueDate != null &&
task.dueDate!.isBefore(task.startDate!)) {
throw ArgumentError(
'A data de entrega não pode ser anterior à data de início.',
);
}
}
}
