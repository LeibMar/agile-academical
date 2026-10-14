
import '../../entities/task.dart';
import '../../repositories/task_repository.dart';
import 'task_rules.dart';

class CreateTask {
  final TaskRepository taskRepository;

  CreateTask({
    required this.taskRepository,
  });

  Future<String> call(Task task) async {
    final taskToCreate = TaskRules.prepareForCreation(task);

    return taskRepository.createTask(taskToCreate);
  }
}
