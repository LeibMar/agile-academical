import '../../entities/app_notification.dart';
import '../../repositories/notification_repository.dart';
import 'notification_rules.dart';

class CreateNotification {
  final NotificationRepository notificationRepository;

  CreateNotification({
    required this.notificationRepository,
  });

  Future<String> call(
      AppNotification notification, {
        DateTime? now,
      }) async {
    final notificationToCreate =
    NotificationRules.prepareForCreation(
      notification,
      now: now,
    );

    return notificationRepository.createNotification(
      notificationToCreate,
    );
  }
}