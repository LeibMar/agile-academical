
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/data/models/app_notification_model.dart';
import 'package:agile_academical_app/domain/entities/app_notification.dart';

void main() {
  final createdAt = DateTime(2026, 11, 1, 9);
  final readAt = DateTime(2026, 11, 2, 10);

  AppNotification makeNotification({
    DateTime? readAt,
  }) {
    return AppNotification(
      id: 'notification-1',
      recipientId: 'user-1',
      projectId: 'project-1',
      type: NotificationType.postCreated,
      actorId: 'user-2',
      entityType: NotificationEntityType.post,
      entityId: 'post-1',
      message: 'Uma nova publicação foi criada.',
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  group('AppNotificationModel', () {
    test('deve converter uma entidade para AppNotificationModel', () {
      final notification = makeNotification(readAt: readAt);

      final model = AppNotificationModel.fromEntity(notification);

      expect(model.id, notification.id);
      expect(model.recipientId, notification.recipientId);
      expect(model.projectId, notification.projectId);
      expect(model.type, notification.type);
      expect(model.actorId, notification.actorId);
      expect(model.entityType, notification.entityType);
      expect(model.entityId, notification.entityId);
      expect(model.message, notification.message);
      expect(model.createdAt, notification.createdAt);
      expect(model.readAt, notification.readAt);
    });

    test('deve converter uma entidade não lida para AppNotificationModel',
            () {
          final notification = makeNotification();

          final model = AppNotificationModel.fromEntity(notification);

          expect(model.readAt, isNull);
          expect(model.isRead, isFalse);
        });

    test('deve converter o modelo para um mapa do Firestore', () {
      final model = AppNotificationModel.fromEntity(
        makeNotification(readAt: readAt),
      );

      final data = model.toFirestore();

      expect(data['recipientId'], 'user-1');
      expect(data['projectId'], 'project-1');
      expect(data['type'], 'postCreated');
      expect(data['actorId'], 'user-2');
      expect(data['entityType'], 'post');
      expect(data['entityId'], 'post-1');
      expect(data['message'], 'Uma nova publicação foi criada.');
      expect(data['createdAt'], createdAt);
      expect(data['readAt'], readAt);
      expect(data.containsKey('id'), isFalse);
    });

    test('deve serializar readAt como null quando não lida', () {
      final model = AppNotificationModel.fromEntity(
        makeNotification(),
      );

      final data = model.toFirestore();

      expect(data['readAt'], isNull);
    });

    test('deve reconstruir o modelo a partir de um documento Firestore',
            () {
          final data = {
            'recipientId': 'user-1',
            'projectId': 'project-1',
            'type': 'postCreated',
            'actorId': 'user-2',
            'entityType': 'post',
            'entityId': 'post-1',
            'message': 'Uma nova publicação foi criada.',
            'createdAt': Timestamp.fromDate(createdAt),
            'readAt': Timestamp.fromDate(readAt),
          };

          final doc = FakeDocumentSnapshot(
            id: 'notification-1',
            data: data,
          );

          final model = AppNotificationModel.fromFirestore(doc);

          expect(model.id, 'notification-1');
          expect(model.recipientId, 'user-1');
          expect(model.projectId, 'project-1');
          expect(model.type, NotificationType.postCreated);
          expect(model.actorId, 'user-2');
          expect(model.entityType, NotificationEntityType.post);
          expect(model.entityId, 'post-1');
          expect(model.message, 'Uma nova publicação foi criada.');
          expect(model.createdAt, createdAt);
          expect(model.readAt, readAt);
          expect(model.isRead, isTrue);
        });

    test('deve reconstruir uma notificação não lida', () {
      final data = {
        'recipientId': 'user-1',
        'projectId': 'project-1',
        'type': 'commentCreated',
        'actorId': 'user-2',
        'entityType': 'comment',
        'entityId': 'comment-1',
        'message': 'Um novo comentário foi criado.',
        'createdAt': Timestamp.fromDate(createdAt),
        'readAt': null,
      };

      final doc = FakeDocumentSnapshot(
        id: 'notification-2',
        data: data,
      );

      final model = AppNotificationModel.fromFirestore(doc);

      expect(model.id, 'notification-2');
      expect(model.type, NotificationType.commentCreated);
      expect(model.entityType, NotificationEntityType.comment);
      expect(model.readAt, isNull);
      expect(model.isRead, isFalse);
    });

    test('deve aceitar DateTime diretamente nos campos de data', () {
      final data = {
        'recipientId': 'user-1',
        'projectId': 'project-1',
        'type': 'taskAssigned',
        'actorId': 'user-2',
        'entityType': 'task',
        'entityId': 'task-1',
        'message': 'Uma tarefa foi atribuída a você.',
        'createdAt': createdAt,
        'readAt': readAt,
      };

      final doc = FakeDocumentSnapshot(
        id: 'notification-3',
        data: data,
      );

      final model = AppNotificationModel.fromFirestore(doc);

      expect(model.createdAt, createdAt);
      expect(model.readAt, readAt);
    });

    test('deve lançar StateError quando o documento não possuir dados', () {
      final doc = FakeDocumentSnapshot(
        id: 'notification-1',
        data: null,
      );

      expect(
            () => AppNotificationModel.fromFirestore(doc),
        throwsA(isA<StateError>()),
      );
    });

    test('deve lançar FormatException quando createdAt estiver ausente',
            () {
          final data = {
            'recipientId': 'user-1',
            'projectId': 'project-1',
            'type': 'postCreated',
            'actorId': 'user-2',
            'entityType': 'post',
            'entityId': 'post-1',
            'message': 'Uma nova publicação foi criada.',
            'readAt': null,
          };

          final doc = FakeDocumentSnapshot(
            id: 'notification-1',
            data: data,
          );

          expect(
                () => AppNotificationModel.fromFirestore(doc),
            throwsA(isA<FormatException>()),
          );
        });

    test('deve lançar FormatException para tipo de data inválido', () {
      final data = {
        'recipientId': 'user-1',
        'projectId': 'project-1',
        'type': 'postCreated',
        'actorId': 'user-2',
        'entityType': 'post',
        'entityId': 'post-1',
        'message': 'Uma nova publicação foi criada.',
        'createdAt': '2026-11-01',
        'readAt': null,
      };

      final doc = FakeDocumentSnapshot(
        id: 'notification-1',
        data: data,
      );

      expect(
            () => AppNotificationModel.fromFirestore(doc),
        throwsA(isA<FormatException>()),
      );
    });

    test('deve lançar ArgumentError para tipo de notificação inválido', () {
      final data = {
        'recipientId': 'user-1',
        'projectId': 'project-1',
        'type': 'invalidType',
        'actorId': 'user-2',
        'entityType': 'post',
        'entityId': 'post-1',
        'message': 'Uma nova publicação foi criada.',
        'createdAt': Timestamp.fromDate(createdAt),
        'readAt': null,
      };

      final doc = FakeDocumentSnapshot(
        id: 'notification-1',
        data: data,
      );

      expect(
            () => AppNotificationModel.fromFirestore(doc),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

class FakeDocumentSnapshot
    extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  final String id;

  final Map<String, dynamic>? _data;

  FakeDocumentSnapshot({
    required this.id,
    required Map<String, dynamic>? data,
  }) : _data = data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => _data != null;
}
