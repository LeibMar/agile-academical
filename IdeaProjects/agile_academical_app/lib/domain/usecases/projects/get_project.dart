
import '../../entities/project.dart';
import '../../repositories/project_repository.dart';

class GetProject {
  final ProjectRepository projectRepository;

  GetProject(this.projectRepository);

  Future<Project?> call(String projectId) {
    final normalizedProjectId = projectId.trim();

    if (normalizedProjectId.isEmpty) {
      throw ArgumentError('O ID do projeto não pode ser vazio.');
    }

    return projectRepository.getProject(normalizedProjectId);
  }
}
