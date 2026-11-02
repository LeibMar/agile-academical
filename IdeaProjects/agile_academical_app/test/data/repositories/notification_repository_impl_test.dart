
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/data/datasources/notification_firestore_datasource.dart';
import 'package:agile_academical_app/data/models/app_notification_model.dart';
import 'package:agile_academical_app/data/repositories/notification_repository_impl.dart';
import 'package:agile_academical_app/domain/entities/app_notification.dart';

class MockNotificationFirestoreDataSource extends Mock
    implements NotificationFirestoreDataSource {}

class FakeAppNotificationModel extends Fake
    implements AppNotificationModel {}

void main() {
  late MockNotificationFirestoreDataSource dataSource;
  late NotificationRepositoryImpl repository;

  final createdAt = DateTime(2026, 11, 1, 9);
  final readAt = DateTime(2026, 11, 2, 10);

  final notification = AppNotification(
    id: 'notification-1',
    recipientId: 'user-1',
    projectId: 'project-1',
    type: NotificationType.postCreated,
    actorId: 'user-2',
    entityType: NotificationEntityType.post,
    entityId: 'post-1',
    message: 'Uma nova publicação foi criada.',
    createdAt: createdAt,
  );

  final readNotification = AppNotification(
    id: 'notification-2',
    recipientId: 'user-1',
    projectId: 'project-1',
    type: NotificationType.commentCreated,
    actorId: 'user-2',
    entityType: NotificationEntityType.comment,
    entityId: 'comment-1',
    message: 'Um novo comentário foi criado.',
    createdAt: createdAt,
    readAt: readAt,
  );

  final notificationModel = AppNotificationModel.fromEntity(notification);
  final readNotificationModel =
  AppNotificationModel.fromEntity(readNotification);

  setUpAll(() {
    registerFallbackValue(FakeAppNotificationModel());
  });

  setUp(() {
    dataSource = MockNotificationFirestoreDataSource();
    repository = NotificationRepositoryImpl(
      dataSource: dataSource,
    );
  });

  group('NotificationRepositoryImpl', () {
    test('deve converter a entidade e delegar a criação ao datasource',
            () async {
          when(() => dataSource.createNotification(any()))
              .thenAnswer((_) async => 'notification-1');

          final result = await repository.createNotification(notification);

          expect(result, 'notification-1');

          final captured = verify(
                () => dataSource.createNotification(captureAny()),
          ).captured.single as AppNotificationModel;

          expect(captured.id, notification.id);
          expect(captured.recipientId, notification.recipientId);
          expect(captured.projectId, notification.projectId);
          expect(captured.type, notification.type);
          expect(captured.actorId, notification.actorId);
          expect(captured.entityType, notification.entityType);
          expect(captured.entityId, notification.entityId);
          expect(captured.message, notification.message);
          expect(captured.createdAt, notification.createdAt);
          expect(captured.readAt, notification.readAt);
        });

    test('deve delegar a busca de uma notificação ao datasource', () async {
      when(() => dataSource.getNotification(
        'user-1',
        'notification-1',
      )).thenAnswer((_) async => notificationModel);

      final result = await repository.getNotification(
        'user-1',
        'notification-1',
      );

      expect(result, isNotNull);
      expect(result!.id, 'notification-1');
      expect(result.recipientId, 'user-1');
      expect(result.message, notification.message);

      verify(
            () => dataSource.getNotification(
          'user-1',
          'notification-1',
        ),
      ).called(1);
    });

    test('deve retornar null quando a notificação não for encontrada',
            () async {
          when(() => dataSource.getNotification(
            'user-1',
            'inexistente',
          )).thenAnswer((_) async => null);

          final result = await repository.getNotification(
            'user-1',
            'inexistente',
          );

          expect(result, isNull);
        });

    test('deve delegar a listagem de notificações ao datasource', () async {
      when(() => dataSource.getNotificationsForUser('user-1'))
          .thenAnswer((_) async => [
        notificationModel,
        readNotificationModel,
      ]);

      final result = await repository.getNotificationsForUser('user-1');

      expect(result, hasLength(2));
      expect(result[0].id, 'notification-1');
      expect(result[1].id, 'notification-2');

      verify(
            () => dataSource.getNotificationsForUser('user-1'),
      ).called(1);
    });

    test('deve delegar a listagem de notificações não lidas ao datasource',
            () async {
          when(() => dataSource.getUnreadNotificationsForUser('user-1'))
              .thenAnswer((_) async => [notificationModel]);

          final result =
          await repository.getUnreadNotificationsForUser('user-1');

          expect(result, hasLength(1));
          expect(result.single.id, 'notification-1');
          expect(result.single.isRead, isFalse);

          verify(
                () => dataSource.getUnreadNotificationsForUser('user-1'),
          ).called(1);
        });

    test('deve converter a entidade e delegar a atualização ao datasource',
            () async {
          when(() => dataSource.updateNotification(any()))
              .thenAnswer((_) async {});

          await repository.updateNotification(readNotification);

          final captured = verify(
                () => dataSource.updateNotification(captureAny()),
          ).captured.single as AppNotificationModel;

          expect(captured.id, readNotification.id);
          expect(captured.recipientId, readNotification.recipientId);
          expect(captured.message, readNotification.message);
          expect(captured.createdAt, readNotification.createdAt);
          expect(captured.readAt, readNotification.readAt);
          expect(captured.isRead, isTrue);
        });

    test('deve delegar a exclusão ao datasource', () async {
      when(() => dataSource.deleteNotification(
        'user-1',
        'notification-1',
      )).thenAnswer((_) async {});

      await repository.deleteNotification(
        'user-1',
        'notification-1',
      );

      verify(
            () => dataSource.deleteNotification(
          'user-1',
          'notification-1',
        ),
      ).called(1);
    });
  });
}
