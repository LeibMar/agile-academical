import '../../entities/app_notification.dart';
import '../../repositories/notification_repository.dart';

class GetNotification {
  final NotificationRepository notificationRepository;

  GetNotification({
    required this.notificationRepository,
  });

  Future<AppNotification?> call({
    required String userId,
    required String notificationId,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError(
        'O ID do usuário não pode ser vazio.',
      );
    }

    if (notificationId.trim().isEmpty) {
      throw ArgumentError(
        'O ID da notificação não pode ser vazio.',
      );
    }

    return notificationRepository.getNotification(
      userId,
      notificationId,
    );
  }
}