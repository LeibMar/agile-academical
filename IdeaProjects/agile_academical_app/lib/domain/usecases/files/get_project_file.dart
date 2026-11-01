import '../../entities/project_file.dart';
import '../../repositories/project_file_repository.dart';

class GetProjectFile {
  final ProjectFileRepository projectFileRepository;

  GetProjectFile({
    required this.projectFileRepository,
  });

  Future<ProjectFile?> call({
    required String projectId,
    required String fileId,
  }) async {
    if (projectId.trim().isEmpty) {
      throw ArgumentError('O ID do projeto não pode ser vazio.');
    }

    if (fileId.trim().isEmpty) {
      throw ArgumentError('O ID do arquivo não pode ser vazio.');
    }

    return projectFileRepository.getFile(projectId, fileId);
  }
}