
import '../../entities/app_notification.dart';

class NotificationRules {
  /// Prepara uma notificação nova antes de enviá-la ao repositório.
  static AppNotification prepareForCreation(
      AppNotification notification, {
        DateTime? now,
      }) {
    _validate(notification);

    final timestamp = now ?? DateTime.now();

    return AppNotification(
      id: notification.id,
      recipientId: notification.recipientId.trim(),
      projectId: notification.projectId.trim(),
      type: notification.type,
      actorId: notification.actorId.trim(),
      entityType: notification.entityType,
      entityId: notification.entityId.trim(),
      message: notification.message.trim(),
      createdAt: timestamp,
      readAt: null,
    );
  }

  static void _validate(AppNotification notification) {
    if (notification.recipientId.trim().isEmpty) {
      throw ArgumentError(
        'A notificação deve possuir um destinatário.',
      );
    }

    if (notification.projectId.trim().isEmpty) {
      throw ArgumentError(
        'A notificação deve estar associada a um projeto.',
      );
    }

    if (notification.actorId.trim().isEmpty) {
      throw ArgumentError(
        'A notificação deve possuir um autor.',
      );
    }

    if (notification.entityId.trim().isEmpty) {
      throw ArgumentError(
        'A notificação deve possuir o ID da entidade relacionada.',
      );
    }

    if (notification.message.trim().isEmpty) {
      throw ArgumentError(
        'A mensagem da notificação não pode ser vazia.',
      );
    }
  }
}
