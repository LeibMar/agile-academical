
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_firestore_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskFirestoreDataSource dataSource;

  TaskRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<String> createTask(Task task) {
    return dataSource.createTask(TaskModel.fromEntity(task));
  }

  @override
  Future<Task?> getTask(String projectId, String taskId) {
    return dataSource.getTask(projectId, taskId);
  }

  @override
  Future<List<Task>> getTasksForProject(String projectId) async {
    return dataSource.getTasksForProject(projectId);
  }

  @override
  Future<void> updateTask(Task task) {
    return dataSource.updateTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String projectId, String taskId) {
    return dataSource.deleteTask(projectId, taskId);
  }
}
