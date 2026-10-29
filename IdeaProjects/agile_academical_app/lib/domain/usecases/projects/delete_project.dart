
import '../../repositories/project_repository.dart';

class DeleteProject {
  final ProjectRepository projectRepository;

  DeleteProject(this.projectRepository);

  Future<void> call(String projectId) async {
    final normalizedProjectId = projectId.trim();

    if (normalizedProjectId.isEmpty) {
      throw ArgumentError('O ID do projeto não pode ser vazio.');
    }

    await projectRepository.deleteProject(normalizedProjectId);
  }
}
