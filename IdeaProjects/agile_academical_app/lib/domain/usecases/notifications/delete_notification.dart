
import '../../repositories/notification_repository.dart';

class DeleteNotification {
  final NotificationRepository notificationRepository;

  DeleteNotification({
    required this.notificationRepository,
  });

  Future<void> call({
    required String userId,
    required String notificationId,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('O ID do usuário não pode ser vazio.');
    }

    if (notificationId.trim().isEmpty) {
      throw ArgumentError('O ID da notificação não pode ser vazio.');
    }

    await notificationRepository.deleteNotification(
      userId,
      notificationId,
    );
  }
}
