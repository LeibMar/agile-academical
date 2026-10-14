
import '../../repositories/task_repository.dart';

class DeleteTask {
  final TaskRepository repository;

  DeleteTask(this.repository);

  Future<void> call(String projectId, String taskId) {
    return repository.deleteTask(projectId, taskId);
  }
}
