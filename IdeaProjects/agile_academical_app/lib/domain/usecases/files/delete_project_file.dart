import '../../repositories/project_file_repository.dart';

class DeleteProjectFile {
  final ProjectFileRepository projectFileRepository;

  DeleteProjectFile({
    required this.projectFileRepository,
  });

  Future<void> call({
    required String projectId,
    required String fileId,
  }) async {
    if (projectId.trim().isEmpty) {
      throw ArgumentError('O ID do projeto não pode ser vazio.');
    }

    if (fileId.trim().isEmpty) {
      throw ArgumentError('O ID do arquivo não pode ser vazio.');
    }

    await projectFileRepository.deleteFile(projectId, fileId);
  }
}