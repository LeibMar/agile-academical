import '../entities/project.dart';

abstract class ProjectRepository {
  Future<String> createProject(Project project);

  Future<Project?> getProject(String projectId);

  Future<List<Project>> getProjectsForUser(String uid);

  Future<void> updateProject(Project project);

  Future<void> addMember(
      String projectId,
      String uid,
      );

  Future<void> removeMember(
      String projectId,
      String uid,
      );

  Future<void> cancelProject(String projectId);

  Future<void> deleteProject(String projectId);
}