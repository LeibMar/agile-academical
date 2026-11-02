enum NotificationType {
  mention,
  postCreated,
  commentCreated,
  fileUploaded,
  taskCreated,
  taskAssigned,
  taskCompleted,
  stageStarted,
  stageCompleted,
}

enum NotificationEntityType {
  post,
  comment,
  file,
  task,
  stage,
}

class AppNotification {
  final String id;
  final String recipientId;
  final String projectId;

  final NotificationType type;

  final String actorId;

  final NotificationEntityType entityType;
  final String entityId;

  final String message;

  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.projectId,
    required this.type,
    required this.actorId,
    required this.entityType,
    required this.entityId,
    required this.message,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;
}