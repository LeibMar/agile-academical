
import '../../entities/project.dart';

class ProjectRules {
  /// Valida e prepara um projeto para criação.
  static Project prepareForCreation(
      Project project, {
        DateTime? now,
      }) {
    _validate(project);

    final timestamp = now ?? DateTime.now();

    return Project(
      id: project.id,
      title: project.title.trim(),
      description: _normalizeDescription(project.description),
      status: project.status,
      ownerId: project.ownerId.trim(),
      advisorId: _normalizeOptionalId(project.advisorId),
      memberIds: _normalizeMembers(
        project.memberIds,
        project.ownerId,
      ),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  /// Valida e prepara um projeto para atualização, preservando
  /// os dados que não podem ser alterados por uma edição comum.
  static Project prepareForUpdate(
      Project current,
      Project updated, {
        DateTime? now,
      }) {
    if (current.id != updated.id) {
      throw ArgumentError(
        'O ID do projeto não pode ser alterado.',
      );
    }

    if (current.ownerId != updated.ownerId) {
      throw ArgumentError(
        'O proprietário do projeto não pode ser alterado '
            'por meio de uma atualização comum.',
      );
    }

    final normalized = Project(
      id: current.id,
      title: updated.title,
      description: updated.description,
      status: updated.status,
      ownerId: current.ownerId,
      advisorId: updated.advisorId,
      memberIds: updated.memberIds,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );

    _validate(normalized);

    return Project(
      id: current.id,
      title: normalized.title.trim(),
      description: _normalizeDescription(normalized.description),
      status: normalized.status,
      ownerId: current.ownerId,
      advisorId: _normalizeOptionalId(normalized.advisorId),
      memberIds: _normalizeMembers(
        normalized.memberIds,
        current.ownerId,
      ),
      createdAt: current.createdAt,
      updatedAt: now ?? DateTime.now(),
    );
  }

  static void _validate(Project project) {
    if (project.title.trim().isEmpty) {
      throw ArgumentError(
        'O título do projeto não pode ser vazio.',
      );
    }

    if (project.ownerId.trim().isEmpty) {
      throw ArgumentError(
        'O projeto deve possuir um proprietário.',
      );
    }

    if (project.memberIds.any((id) => id.trim().isEmpty)) {
      throw ArgumentError(
        'A lista de membros não pode conter IDs vazios.',
      );
    }

    if (project.advisorId != null &&
        project.advisorId!.trim().isEmpty) {
      throw ArgumentError(
        'O ID do orientador não pode ser vazio.',
      );
    }
  }

  static String? _normalizeDescription(String? description) {
    if (description == null) {
      return null;
    }

    final normalized = description.trim();

    return normalized.isEmpty ? null : normalized;
  }

  static String? _normalizeOptionalId(String? id) {
    if (id == null) {
      return null;
    }

    final normalized = id.trim();

    return normalized.isEmpty ? null : normalized;
  }

  static List<String> _normalizeMembers(
      List<String> memberIds,
      String ownerId,
      ) {
    final normalizedMembers = memberIds
        .map((id) => id.trim())
        .toSet();

    normalizedMembers.add(ownerId.trim());

    return List<String>.unmodifiable(
      normalizedMembers.toList(),
    );
  }
}
