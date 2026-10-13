
enum TaskStatus {
  backlog,
  todo,
  inProgress,
  inReview,
  done,
}

enum TaskPriority {
  low,
  medium,
  high,
  critical,
}

class Task {
  final String id;
  final String projectId;
  final String? stageId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assignedTo;
  final String createdBy;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.projectId,
    this.stageId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assignedTo,
    required this.createdBy,
    this.startDate,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
