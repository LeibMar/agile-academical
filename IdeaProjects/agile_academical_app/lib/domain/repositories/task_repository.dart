
import '../entities/task.dart';

abstract class TaskRepository {
  Future<String> createTask(Task task);

  Future<Task?> getTask(String projectId, String taskId);

  Future<List<Task>> getTasksForProject(String projectId);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String projectId, String taskId);
}
