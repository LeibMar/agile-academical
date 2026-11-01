
enum FileSourceType {
  uploaded,
  externalLink,
}

enum FileRelatedEntityType {
  post,
  task,
  stage,
}

class ProjectFile {
  final String id;
  final String projectId;
  final String name;
  final String? description;

  final FileSourceType sourceType;

  // Utilizado quando o arquivo foi enviado ao Firebase Storage.
  final String? storagePath;
  final String? contentType;
  final int? sizeBytes;

  // Utilizado quando o arquivo é um link externo.
  final String? externalUrl;

  final String uploadedBy;

  // Associação opcional com publicação, tarefa ou etapa.
  final FileRelatedEntityType? relatedEntityType;
  final String? relatedEntityId;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectFile({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.sourceType,
    this.storagePath,
    this.contentType,
    this.sizeBytes,
    this.externalUrl,
    required this.uploadedBy,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.createdAt,
    required this.updatedAt,
  });
}
