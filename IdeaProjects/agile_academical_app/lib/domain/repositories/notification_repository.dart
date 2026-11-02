import '../entities/app_notification.dart';

abstract class NotificationRepository {
  /// Cria uma notificação para um usuário.
  ///
  /// Retorna o ID do documento criado.
  Future<String> createNotification(
      AppNotification notification,
      );

  /// Busca uma notificação específica de um usuário.
  ///
  /// Retorna null caso não exista.
  Future<AppNotification?> getNotification(
      String userId,
      String notificationId,
      );

  /// Lista todas as notificações de um usuário.
  Future<List<AppNotification>> getNotificationsForUser(
      String userId,
      );

  /// Lista somente as notificações não lidas de um usuário.
  Future<List<AppNotification>> getUnreadNotificationsForUser(
      String userId,
      );

  /// Atualiza os dados de uma notificação.
  ///
  /// Será utilizado principalmente para registrar a leitura.
  Future<void> updateNotification(
      AppNotification notification,
      );

  /// Exclui uma notificação específica de um usuário.
  Future<void> deleteNotification(
      String userId,
      String notificationId,
      );
}