
import '../../domain/entities/project_file.dart';
import '../../domain/repositories/project_file_repository.dart';
import '../datasources/project_file_firestore_datasource.dart';
import '../models/project_file_model.dart';

class ProjectFileRepositoryImpl implements ProjectFileRepository {
  final ProjectFileFirestoreDataSource dataSource;

  ProjectFileRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<String> createFile(ProjectFile file) async {
    final model = ProjectFileModel.fromEntity(file);
    return dataSource.createFile(model);
  }

  @override
  Future<ProjectFile?> getFile(
      String projectId,
      String fileId,
      ) async {
    return dataSource.getFile(projectId, fileId);
  }

  @override
  Future<List<ProjectFile>> getFilesForProject(
      String projectId,
      ) async {
    return dataSource.getFilesForProject(projectId);
  }

  @override
  Future<List<ProjectFile>> getFilesForRelatedEntity({
    required String projectId,
    required FileRelatedEntityType relatedEntityType,
    required String relatedEntityId,
  }) async {
    return dataSource.getFilesForRelatedEntity(
      projectId: projectId,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
    );
  }

  @override
  Future<void> updateFile(ProjectFile file) async {
    final model = ProjectFileModel.fromEntity(file);
    await dataSource.updateFile(model);
  }

  @override
  Future<void> deleteFile(String projectId, String fileId) async {
    await dataSource.deleteFile(projectId, fileId);
  }
}
