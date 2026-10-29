
import '../../repositories/project_repository.dart';

class RemoveProjectMember {
  final ProjectRepository projectRepository;

  RemoveProjectMember(this.projectRepository);

  Future<void> call({
    required String projectId,
    required String userId,
    required String ownerId,
  }) async {
    final normalizedProjectId = projectId.trim();
    final normalizedUserId = userId.trim();
    final normalizedOwnerId = ownerId.trim();

    if (normalizedProjectId.isEmpty) {
      throw ArgumentError('O ID do projeto não pode ser vazio.');
    }

    if (normalizedUserId.isEmpty) {
      throw ArgumentError('O ID do usuário não pode ser vazio.');
    }

    if (normalizedOwnerId.isEmpty) {
      throw ArgumentError('O ID do proprietário não pode ser vazio.');
    }

    if (normalizedUserId == normalizedOwnerId) {
      throw StateError(
        'O proprietário do projeto não pode ser removido.',
      );
    }

    await projectRepository.removeMember(
      normalizedProjectId,
      normalizedUserId,
    );
  }
}
