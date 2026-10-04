enum ProjectStatus {
  planning,
  inProgress,
  completed,
  cancelled,
}

class Project {
  final String id;
  final String title;
  final String? description;
  final ProjectStatus status;
  final String ownerId;
  final String? advisorId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.ownerId,
    this.advisorId,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
  });
}