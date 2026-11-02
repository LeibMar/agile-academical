import '../../entities/app_notification.dart';
import '../../repositories/notification_repository.dart';

class GetUnreadNotificationsForUser {
  final NotificationRepository notificationRepository;

  GetUnreadNotificationsForUser({
    required this.notificationRepository,
  });

  Future<List<AppNotification>> call(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError(
        'O ID do usuário não pode ser vazio.',
      );
    }

    return notificationRepository.getUnreadNotificationsForUser(
      userId,
    );
  }
}