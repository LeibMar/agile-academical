
import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

class UpdateTask {
final TaskRepository repository;

UpdateTask(this.repository);

Future<void> call(Task task) {
return repository.updateTask(task);
}
}
