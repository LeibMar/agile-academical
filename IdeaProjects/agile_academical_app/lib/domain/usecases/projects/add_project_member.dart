
import '../../repositories/project_repository.dart';

class AddProjectMember {
  final ProjectRepository projectRepository;

  AddProjectMember(this.projectRepository);

  Future<void> call({
    required String projectId,
    required String userId,
  }) async {
    final normalizedProjectId = projectId.trim();
    final normalizedUserId = userId.trim();

    if (normalizedProjectId.isEmpty) {
      throw ArgumentError('O ID do projeto não pode ser vazio.');
    }

    if (normalizedUserId.isEmpty) {
      throw ArgumentError('O ID do usuário não pode ser vazio.');
    }

    await projectRepository.addMember(
      normalizedProjectId,
      normalizedUserId,
    );
  }
}
