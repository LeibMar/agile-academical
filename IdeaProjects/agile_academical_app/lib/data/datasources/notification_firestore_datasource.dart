
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification_model.dart';

class NotificationFirestoreDataSource {
  final FirebaseFirestore firestore;

  NotificationFirestoreDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notificationsCollection(
      String userId,
      ) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  // Cria uma notificação e retorna o ID gerado pelo Firestore.
  Future<String> createNotification(
      AppNotificationModel notification,
      ) async {
    final docRef = _notificationsCollection(notification.recipientId).doc();

    final data = notification.toFirestore()
      ..['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);

    return docRef.id;
  }

  // Busca uma notificação pelo usuário e pelo ID.
  // Retorna null caso o documento não exista.
  Future<AppNotificationModel?> getNotification(
      String userId,
      String notificationId,
      ) async {
    final doc = await _notificationsCollection(userId)
        .doc(notificationId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return AppNotificationModel.fromFirestore(doc);
  }

  // Lista todas as notificações do usuário, da mais recente para a mais antiga.
  Future<List<AppNotificationModel>> getNotificationsForUser(
      String userId,
      ) async {
    final snapshot = await _notificationsCollection(userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AppNotificationModel.fromFirestore(doc))
        .toList();
  }

  // Lista notificações não lidas, ordenadas da mais recente para a mais antiga.
  Future<List<AppNotificationModel>> getUnreadNotificationsForUser(
      String userId,
      ) async {
    final snapshot = await _notificationsCollection(userId)
        .where('readAt', isNull: true)
        .get();

    final notifications = snapshot.docs
        .map((doc) => AppNotificationModel.fromFirestore(doc))
        .toList();

    notifications.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return notifications;
  }

  // Atualiza os dados sem alterar a data de criação.
  Future<void> updateNotification(
      AppNotificationModel notification,
      ) async {
    final data = notification.toFirestore();

    data.remove('createdAt');

    await _notificationsCollection(notification.recipientId)
        .doc(notification.id)
        .update(data);
  }

  // Exclui uma notificação do usuário.
  Future<void> deleteNotification(
      String userId,
      String notificationId,
      ) async {
    await _notificationsCollection(userId)
        .doc(notificationId)
        .delete();
  }
}
