import '../../entities/project_file.dart';
import '../../repositories/project_file_repository.dart';
import 'project_file_rules.dart';

class CreateProjectFile {
  final ProjectFileRepository projectFileRepository;

  CreateProjectFile({
    required this.projectFileRepository,
  });

  Future<String> call(
      ProjectFile file, {
        DateTime? now,
      }) async {
    final fileToCreate = ProjectFileRules.prepareForCreation(
      file,
      now: now,
    );

    return projectFileRepository.createFile(fileToCreate);
  }
}