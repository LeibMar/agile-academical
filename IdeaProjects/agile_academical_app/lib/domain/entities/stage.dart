enum StageStatus {
  planning,
  inProgress,
  completed,
  cancelled,
}

class Stage {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final StageStatus status;
  final int order;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Stage({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    required this.order,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });
}
