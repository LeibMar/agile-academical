
import '../../entities/project_file.dart';

class ProjectFileRules {
  static ProjectFile prepareForCreation(
      ProjectFile file, {
        DateTime? now,
      }) {
    _validate(file);

    final timestamp = now ?? DateTime.now();

    return ProjectFile(
      id: file.id,
      projectId: file.projectId,
      name: file.name.trim(),
      description: file.description?.trim(),
      sourceType: file.sourceType,
      storagePath: file.storagePath,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      externalUrl: file.externalUrl?.trim(),
      uploadedBy: file.uploadedBy,
      relatedEntityType: file.relatedEntityType,
      relatedEntityId: file.relatedEntityId,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  static ProjectFile prepareForUpdate(
      ProjectFile current,
      ProjectFile updated, {
        DateTime? now,
      }) {
    if (current.id != updated.id) {
      throw ArgumentError(
        'Não é permitido alterar o ID do arquivo.',
      );
    }

    if (current.projectId != updated.projectId) {
      throw ArgumentError(
        'Não é permitido transferir o arquivo para outro projeto.',
      );
    }

    if (current.uploadedBy != updated.uploadedBy) {
      throw ArgumentError(
        'Não é permitido alterar o responsável pelo envio.',
      );
    }

    if (current.sourceType != updated.sourceType ||
        current.storagePath != updated.storagePath ||
        current.externalUrl != updated.externalUrl) {
      throw ArgumentError(
        'Não é permitido alterar a origem do arquivo.',
      );
    }

    final fileToUpdate = ProjectFile(
      id: current.id,
      projectId: current.projectId,
      name: updated.name.trim(),
      description: updated.description?.trim(),
      sourceType: current.sourceType,
      storagePath: current.storagePath,
      contentType: current.contentType,
      sizeBytes: current.sizeBytes,
      externalUrl: current.externalUrl,
      uploadedBy: current.uploadedBy,
      relatedEntityType: updated.relatedEntityType,
      relatedEntityId: updated.relatedEntityId,
      createdAt: current.createdAt,
      updatedAt: now ?? DateTime.now(),
    );

    _validate(fileToUpdate);

    return fileToUpdate;
  }

  static void _validate(ProjectFile file) {
    if (file.projectId.trim().isEmpty) {
      throw ArgumentError(
        'O arquivo deve estar associado a um projeto.',
      );
    }

    if (file.name.trim().isEmpty) {
      throw ArgumentError(
        'O nome do arquivo não pode ser vazio.',
      );
    }

    if (file.uploadedBy.trim().isEmpty) {
      throw ArgumentError(
        'O arquivo deve possuir um responsável pelo envio.',
      );
    }

    if (file.relatedEntityType == null &&
        file.relatedEntityId != null) {
      throw ArgumentError(
        'O ID da entidade relacionada exige um tipo de entidade.',
      );
    }

    if (file.relatedEntityType != null &&
        (file.relatedEntityId == null ||
            file.relatedEntityId!.trim().isEmpty)) {
      throw ArgumentError(
        'A entidade relacionada deve possuir um ID válido.',
      );
    }

    switch (file.sourceType) {
      case FileSourceType.uploaded:
        if (file.storagePath == null ||
            file.storagePath!.trim().isEmpty) {
          throw ArgumentError(
            'Um arquivo enviado deve possuir um caminho no Storage.',
          );
        }

        if (file.externalUrl != null) {
          throw ArgumentError(
            'Um arquivo enviado não deve possuir URL externa.',
          );
        }

        if (file.sizeBytes != null && file.sizeBytes! < 0) {
          throw ArgumentError(
            'O tamanho do arquivo não pode ser negativo.',
          );
        }

      case FileSourceType.externalLink:
        if (file.externalUrl == null ||
            file.externalUrl!.trim().isEmpty) {
          throw ArgumentError(
            'Um link externo deve possuir uma URL.',
          );
        }

        final uri = Uri.tryParse(file.externalUrl!.trim());

        if (uri == null ||
            !uri.hasAuthority ||
            (uri.scheme != 'http' && uri.scheme != 'https')) {
          throw ArgumentError(
            'A URL externa deve utilizar HTTP ou HTTPS.',
          );
        }

        if (file.storagePath != null) {
          throw ArgumentError(
            'Um link externo não deve possuir caminho no Storage.',
          );
        }
    }
  }
}
