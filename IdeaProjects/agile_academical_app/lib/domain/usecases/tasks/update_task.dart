
import '../../entities/task.dart';
import '../../repositories/task_repository.dart';
import 'task_rules.dart';

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  Future<void> call(Task task) async {
    final current = await repository.getTask(
      task.projectId,
      task.id,
    );

    if (current == null) {
      throw StateError(
        'A tarefa não foi encontrada para atualização.',
      );
    }

    final taskToUpdate = TaskRules.prepareForUpdate(
      current,
      task,
    );

    await repository.updateTask(taskToUpdate);
  }
}
