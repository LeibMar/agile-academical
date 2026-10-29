
import '../../entities/project.dart';
import '../../repositories/project_repository.dart';
import 'project_rules.dart';

class UpdateProject {
  final ProjectRepository projectRepository;

  UpdateProject(this.projectRepository);

  Future<void> call(Project current, Project updated) async {
    final preparedProject = ProjectRules.prepareForUpdate(
      current,
      updated,
    );

    await projectRepository.updateProject(preparedProject);
  }
}
