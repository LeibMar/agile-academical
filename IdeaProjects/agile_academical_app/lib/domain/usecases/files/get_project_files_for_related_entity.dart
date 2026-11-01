import '../../entities/project_file.dart';
import '../../repositories/project_file_repository.dart';

class GetProjectFilesForRelatedEntity {
  final ProjectFileRepository projectFileRepository;

  GetProjectFilesForRelatedEntity({
    required this.projectFileRepository,
  });

  Future<List<ProjectFile>> call({
    required String projectId,
    required FileRelatedEntityType relatedEntityType,
    required String relatedEntityId,
  }) async {
    if (projectId.trim().isEmpty) {
      throw ArgumentError('O ID do projeto não pode ser vazio.');
    }

    if (relatedEntityId.trim().isEmpty) {
      throw ArgumentError('O ID da entidade relacionada não pode ser vazio.');
    }

    return projectFileRepository.getFilesForRelatedEntity(
      projectId: projectId,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
    );
  }
}