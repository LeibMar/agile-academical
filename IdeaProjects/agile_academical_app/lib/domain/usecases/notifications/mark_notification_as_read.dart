
import '../../entities/app_notification.dart';
import '../../repositories/notification_repository.dart';

class MarkNotificationAsRead {
  final NotificationRepository notificationRepository;

  MarkNotificationAsRead({
    required this.notificationRepository,
  });

  Future<void> call({
    required String userId,
    required String notificationId,
    DateTime? now,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('O ID do usuário não pode ser vazio.');
    }

    if (notificationId.trim().isEmpty) {
      throw ArgumentError('O ID da notificação não pode ser vazio.');
    }

    final notification = await notificationRepository.getNotification(
      userId,
      notificationId,
    );

    if (notification == null) {
      throw StateError(
        'A notificação não foi encontrada para atualização.',
      );
    }

    // Não atualiza novamente uma notificação já lida.
    if (notification.isRead) {
      return;
    }

    final updatedNotification = AppNotification(
      id: notification.id,
      recipientId: notification.recipientId,
      projectId: notification.projectId,
      type: notification.type,
      actorId: notification.actorId,
      entityType: notification.entityType,
      entityId: notification.entityId,
      message: notification.message,
      createdAt: notification.createdAt,
      readAt: now ?? DateTime.now(),
    );

    await notificationRepository.updateNotification(
      updatedNotification,
    );
  }
}
