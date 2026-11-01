
import '../entities/project_file.dart';

abstract class ProjectFileRepository {
  /// Cria os metadados de um arquivo vinculado a um projeto.
  ///
  /// Retorna o ID do documento criado.
  Future<String> createFile(ProjectFile file);

  /// Busca um arquivo específico dentro de um projeto.
  Future<ProjectFile?> getFile(String projectId, String fileId);

  /// Lista todos os arquivos vinculados a um projeto.
  Future<List<ProjectFile>> getFilesForProject(String projectId);

  /// Lista os arquivos associados a uma publicação, tarefa ou etapa.
  Future<List<ProjectFile>> getFilesForRelatedEntity({
    required String projectId,
    required FileRelatedEntityType relatedEntityType,
    required String relatedEntityId,
  });

  /// Atualiza os metadados de um arquivo.
  Future<void> updateFile(ProjectFile file);

  /// Exclui os metadados de um arquivo.
  ///
  /// A exclusão do conteúdo binário no Storage será responsabilidade
  /// da camada de armazenamento, a ser implementada separadamente.
  Future<void> deleteFile(String projectId, String fileId);
}
