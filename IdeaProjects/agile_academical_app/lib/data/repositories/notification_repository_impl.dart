
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_firestore_datasource.dart';
import '../models/app_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationFirestoreDataSource dataSource;

  NotificationRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<String> createNotification(
      AppNotification notification,
      ) async {
    final model = AppNotificationModel.fromEntity(notification);
    return dataSource.createNotification(model);
  }

  @override
  Future<AppNotification?> getNotification(
      String userId,
      String notificationId,
      ) async {
    return dataSource.getNotification(userId, notificationId);
  }

  @override
  Future<List<AppNotification>> getNotificationsForUser(
      String userId,
      ) async {
    return dataSource.getNotificationsForUser(userId);
  }

  @override
  Future<List<AppNotification>> getUnreadNotificationsForUser(
      String userId,
      ) async {
    return dataSource.getUnreadNotificationsForUser(userId);
  }

  @override
  Future<void> updateNotification(
      AppNotification notification,
      ) async {
    final model = AppNotificationModel.fromEntity(notification);
    await dataSource.updateNotification(model);
  }

  @override
  Future<void> deleteNotification(
      String userId,
      String notificationId,
      ) async {
    await dataSource.deleteNotification(userId, notificationId);
  }
}
