
import '../../entities/project_file.dart';
import '../../repositories/project_file_repository.dart';
import 'project_file_rules.dart';

class UpdateProjectFile {
  final ProjectFileRepository projectFileRepository;

  UpdateProjectFile({
    required this.projectFileRepository,
  });

  Future<void> call(
      ProjectFile file, {
        DateTime? now,
      }) async {
    if (file.id.trim().isEmpty) {
      throw ArgumentError(
        'O ID do arquivo não pode ser vazio.',
      );
    }

    if (file.projectId.trim().isEmpty) {
      throw ArgumentError(
        'O ID do projeto não pode ser vazio.',
      );
    }

    final currentFile = await projectFileRepository.getFile(
      file.projectId,
      file.id,
    );

    if (currentFile == null) {
      throw StateError(
        'O arquivo informado não foi encontrado.',
      );
    }

    final fileToUpdate = ProjectFileRules.prepareForUpdate(
      currentFile,
      file,
      now: now,
    );

    await projectFileRepository.updateFile(fileToUpdate);
  }
}
