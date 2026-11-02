import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/app_notification.dart';
import 'package:agile_academical_app/domain/usecases/notifications/notification_rules.dart';

void main() {
  group('NotificationRules', () {
    final now = DateTime(2026, 11, 2, 12);

    AppNotification makeNotification({
      String recipientId = 'user-2',
      String projectId = 'project-1',
      String actorId = 'user-1',
      String entityId = 'post-1',
      String message = 'Nova publicação no projeto.',
      DateTime? readAt,
    }) {
      return AppNotification(
        id: 'notification-1',
        recipientId: recipientId,
        projectId: projectId,
        type: NotificationType.postCreated,
        actorId: actorId,
        entityType: NotificationEntityType.post,
        entityId: entityId,
        message: message,
        createdAt: now.subtract(const Duration(minutes: 5)),
        readAt: readAt,
      );
    }

    group('prepareForCreation', () {
      test('deve preparar corretamente uma notificação nova', () {
        final notification = makeNotification(
          recipientId: '  user-2  ',
          projectId: '  project-1  ',
          actorId: '  user-1  ',
          entityId: '  post-1  ',
          message: '  Nova publicação no projeto.  ',
        );

        final result = NotificationRules.prepareForCreation(
          notification,
          now: now,
        );

        expect(result.id, 'notification-1');
        expect(result.recipientId, 'user-2');
        expect(result.projectId, 'project-1');
        expect(result.actorId, 'user-1');
        expect(result.entityId, 'post-1');
        expect(result.message, 'Nova publicação no projeto.');
        expect(result.type, NotificationType.postCreated);
        expect(result.entityType, NotificationEntityType.post);
        expect(result.createdAt, now);
        expect(result.readAt, isNull);
        expect(result.isRead, isFalse);
      });

      test('deve iniciar a notificação como não lida', () {
        final notification = makeNotification(
          readAt: now.subtract(const Duration(minutes: 1)),
        );

        final result = NotificationRules.prepareForCreation(
          notification,
          now: now,
        );

        expect(result.readAt, isNull);
        expect(result.isRead, isFalse);
      });

      test('deve rejeitar destinatário vazio', () {
        expect(
              () => NotificationRules.prepareForCreation(
            makeNotification(recipientId: '  '),
            now: now,
          ),
          throwsArgumentError,
        );
      });

      test('deve rejeitar projeto vazio', () {
        expect(
              () => NotificationRules.prepareForCreation(
            makeNotification(projectId: '  '),
            now: now,
          ),
          throwsArgumentError,
        );
      });

      test('deve rejeitar autor vazio', () {
        expect(
              () => NotificationRules.prepareForCreation(
            makeNotification(actorId: '  '),
            now: now,
          ),
          throwsArgumentError,
        );
      });

      test('deve rejeitar ID da entidade relacionado vazio', () {
        expect(
              () => NotificationRules.prepareForCreation(
            makeNotification(entityId: '  '),
            now: now,
          ),
          throwsArgumentError,
        );
      });

      test('deve rejeitar mensagem vazia', () {
        expect(
              () => NotificationRules.prepareForCreation(
            makeNotification(message: '  '),
            now: now,
          ),
          throwsArgumentError,
        );
      });
    });
  });
}