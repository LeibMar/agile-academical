
import '../../entities/project.dart';
import '../../repositories/project_repository.dart';
import 'project_rules.dart';

class CreateProject {
  final ProjectRepository projectRepository;

  CreateProject(this.projectRepository);

  Future<String> call(Project project) async {
    final preparedProject = ProjectRules.prepareForCreation(project);
    return projectRepository.createProject(preparedProject);
  }
}
