import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_firestore_datasource.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectFirestoreDataSource dataSource;

  ProjectRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<String> createProject(Project project) {
    final model = ProjectModel.fromEntity(project);

    return dataSource.createProject(model);
  }

  @override
  Future<Project?> getProject(String projectId) {
    return dataSource.getProject(projectId);
  }

  @override
  Future<List<Project>> getProjectsForUser(String uid) {
    return dataSource.getProjectsForUser(uid);
  }

  @override
  Future<void> updateProject(Project project) {
    final model = ProjectModel.fromEntity(project);

    return dataSource.updateProject(model);
  }

  @override
  Future<void> addMember(
      String projectId,
      String uid,
      ) {
    return dataSource.addMember(projectId, uid);
  }

  @override
  Future<void> removeMember(
      String projectId,
      String uid,
      ) {
    return dataSource.removeMember(projectId, uid);
  }

  @override
  Future<void> cancelProject(String projectId) {
    return dataSource.cancelProject(projectId);
  }

  @override
  Future<void> deleteProject(String projectId) {
    return dataSource.deleteProject(projectId);
  }
}