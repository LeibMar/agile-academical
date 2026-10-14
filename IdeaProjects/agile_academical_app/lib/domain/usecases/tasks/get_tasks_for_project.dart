
import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

class GetTasksForProject {
  final TaskRepository repository;

  GetTasksForProject(this.repository);

  Future<List<Task>> call(String projectId) {
    return repository.getTasksForProject(projectId);
  }
}
