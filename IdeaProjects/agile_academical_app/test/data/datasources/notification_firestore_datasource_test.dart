import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/data/datasources/notification_firestore_datasource.dart';
import 'package:agile_academical_app/data/models/app_notification_model.dart';
import 'package:agile_academical_app/domain/entities/app_notification.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late NotificationFirestoreDataSource datasource;

  final createdAt = DateTime(2026, 11, 1, 9);
  final secondCreatedAt = DateTime(2026, 11, 2, 9);
  final readAt = DateTime(2026, 11, 3, 9);

  AppNotificationModel makeNotification({
    String id = 'notification-1',
    String recipientId = 'user-1',
    String message = 'Uma nova publicação foi criada.',
    DateTime? notificationCreatedAt,
    DateTime? notificationReadAt,
  }) {
    return AppNotificationModel(
      id: id,
      recipientId: recipientId,
      projectId: 'project-1',
      type: NotificationType.postCreated,
      actorId: 'user-2',
      entityType: NotificationEntityType.post,
      entityId: 'post-1',
      message: message,
      createdAt: notificationCreatedAt ?? createdAt,
      readAt: notificationReadAt,
    );
  }

  Future<void> seedNotification({
    required String id,
    required DateTime notificationCreatedAt,
    DateTime? notificationReadAt,
    String message = 'Uma notificação de teste.',
  }) async {
    await firestore
        .collection('users')
        .doc('user-1')
        .collection('notifications')
        .doc(id)
        .set({
      'recipientId': 'user-1',
      'projectId': 'project-1',
      'type': 'postCreated',
      'actorId': 'user-2',
      'entityType': 'post',
      'entityId': 'post-1',
      'message': message,
      'createdAt': Timestamp.fromDate(notificationCreatedAt),
      'readAt': notificationReadAt == null
          ? null
          : Timestamp.fromDate(notificationReadAt),
    });
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = NotificationFirestoreDataSource(
      firestore: firestore,
    );
  });

  group('NotificationFirestoreDataSource', () {
    test('deve criar uma notificação e retornar o ID gerado', () async {
      final notification = makeNotification();

      final id = await datasource.createNotification(notification);

      expect(id, isNotEmpty);

      final doc = await firestore
          .collection('users')
          .doc('user-1')
          .collection('notifications')
          .doc(id)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()?['recipientId'], 'user-1');
      expect(doc.data()?['projectId'], 'project-1');
      expect(doc.data()?['type'], 'postCreated');
      expect(doc.data()?['actorId'], 'user-2');
      expect(doc.data()?['entityType'], 'post');
      expect(doc.data()?['entityId'], 'post-1');
      expect(doc.data()?['message'], notification.message);
      expect(doc.data()?['readAt'], isNull);
      expect(doc.data()?['createdAt'], isNotNull);
    });

    test('deve buscar uma notificação existente', () async {
      final id = await datasource.createNotification(
        makeNotification(),
      );

      final notification = await datasource.getNotification(
        'user-1',
        id,
      );

      expect(notification, isNotNull);
      expect(notification!.id, id);
      expect(notification.recipientId, 'user-1');
      expect(notification.projectId, 'project-1');
      expect(notification.type, NotificationType.postCreated);
      expect(notification.isRead, isFalse);
    });

    test('deve retornar null quando a notificação não existir', () async {
      final notification = await datasource.getNotification(
        'user-1',
        'inexistente',
      );

      expect(notification, isNull);
    });

    test('deve listar todas as notificações em ordem decrescente', () async {
      await seedNotification(
        id: 'notification-1',
        notificationCreatedAt: createdAt,
        message: 'Mais antiga',
      );

      await seedNotification(
        id: 'notification-2',
        notificationCreatedAt: secondCreatedAt,
        message: 'Mais recente',
      );

      final notifications = await datasource.getNotificationsForUser(
        'user-1',
      );

      expect(notifications, hasLength(2));
      expect(notifications.first.message, 'Mais recente');
      expect(notifications.last.message, 'Mais antiga');
    });

    test('deve retornar lista vazia quando não houver notificações', () async {
      final notifications = await datasource.getNotificationsForUser(
        'user-1',
      );

      expect(notifications, isEmpty);
    });

    test('deve listar somente notificações não lidas', () async {
      await seedNotification(
        id: 'notification-1',
        notificationCreatedAt: createdAt,
      );

      await seedNotification(
        id: 'notification-2',
        notificationCreatedAt: secondCreatedAt,
        notificationReadAt: readAt,
      );

      final notifications =
      await datasource.getUnreadNotificationsForUser('user-1');

      expect(notifications, hasLength(1));
      expect(notifications.single.id, 'notification-1');
      expect(notifications.single.isRead, isFalse);
    });

    test(
      'deve ordenar notificações não lidas da mais recente para a mais antiga',
          () async {
        await seedNotification(
          id: 'notification-1',
          notificationCreatedAt: createdAt,
          message: 'Mais antiga',
        );

        await seedNotification(
          id: 'notification-2',
          notificationCreatedAt: secondCreatedAt,
          message: 'Mais recente',
        );

        final notifications =
        await datasource.getUnreadNotificationsForUser('user-1');

        expect(notifications, hasLength(2));
        expect(notifications.first.message, 'Mais recente');
        expect(notifications.last.message, 'Mais antiga');
      },
    );

    test('deve atualizar uma notificação existente', () async {
      final id = await datasource.createNotification(
        makeNotification(),
      );

      final original = await datasource.getNotification('user-1', id);
      expect(original, isNotNull);

      final updated = AppNotificationModel(
        id: id,
        recipientId: original!.recipientId,
        projectId: original.projectId,
        type: original.type,
        actorId: original.actorId,
        entityType: original.entityType,
        entityId: original.entityId,
        message: 'Notificação atualizada.',
        createdAt: original.createdAt,
        readAt: readAt,
      );

      await datasource.updateNotification(updated);

      final result = await datasource.getNotification('user-1', id);

      expect(result, isNotNull);
      expect(result!.message, 'Notificação atualizada.');
      expect(result.readAt, isNotNull);
      expect(result.isRead, isTrue);
      expect(result.createdAt, original.createdAt);
    });

    test('deve excluir uma notificação existente', () async {
      final id = await datasource.createNotification(
        makeNotification(),
      );

      await datasource.deleteNotification('user-1', id);

      final notification = await datasource.getNotification(
        'user-1',
        id,
      );

      expect(notification, isNull);
    });

    test('deve manter notificações de usuários diferentes isoladas', () async {
      await datasource.createNotification(
        makeNotification(
          id: 'notification-1',
          recipientId: 'user-1',
        ),
      );

      await datasource.createNotification(
        makeNotification(
          id: 'notification-2',
          recipientId: 'user-2',
        ),
      );

      final user1Notifications =
      await datasource.getNotificationsForUser('user-1');

      final user2Notifications =
      await datasource.getNotificationsForUser('user-2');

      expect(user1Notifications, hasLength(1));
      expect(user1Notifications.single.recipientId, 'user-1');

      expect(user2Notifications, hasLength(1));
      expect(user2Notifications.single.recipientId, 'user-2');
    });
  });
}
