
import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

class GetTask {
  final TaskRepository repository;

  GetTask(this.repository);

  Future<Task?> call(String projectId, String taskId) {
    return repository.getTask(projectId, taskId);
  }
}
