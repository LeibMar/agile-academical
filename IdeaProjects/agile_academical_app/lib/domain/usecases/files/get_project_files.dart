import '../../entities/project_file.dart';
import '../../repositories/project_file_repository.dart';

class GetProjectFiles {
  final ProjectFileRepository projectFileRepository;

  GetProjectFiles({
    required this.projectFileRepository,
  });

  Future<List<ProjectFile>> call(String projectId) async {
    if (projectId.trim().isEmpty) {
      throw ArgumentError('O ID do projeto não pode ser vazio.');
    }

    return projectFileRepository.getFilesForProject(projectId);
  }
}