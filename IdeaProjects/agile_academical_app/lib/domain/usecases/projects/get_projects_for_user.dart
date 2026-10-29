
import '../../entities/project.dart';
import '../../repositories/project_repository.dart';

class GetProjectsForUser {
  final ProjectRepository projectRepository;

  GetProjectsForUser(this.projectRepository);

  Future<List<Project>> call(String userId) {
    final normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      throw ArgumentError('O ID do usuário não pode ser vazio.');
    }

    return projectRepository.getProjectsForUser(normalizedUserId);
  }
}
