import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/app_notification.dart';
import 'package:agile_academical_app/domain/repositories/notification_repository.dart';
import 'package:agile_academical_app/domain/usecases/notifications/create_notification.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository notificationRepository;
  late CreateNotification createNotification;

  setUpAll(() {
    registerFallbackValue(
      AppNotification(
        id: '',
        recipientId: '',
        projectId: '',
        type: NotificationType.postCreated,
        actorId: '',
        entityType: NotificationEntityType.post,
        entityId: '',
        message: '',
        createdAt: DateTime(2000),
      ),
    );
  });

  setUp(() {
    notificationRepository = MockNotificationRepository();

    createNotification = CreateNotification(
      notificationRepository: notificationRepository,
    );
  });

  group('CreateNotification', () {
    test('deve preparar a notificação e retornar seu ID', () async {
      final now = DateTime(2026, 11, 2, 12);

      final notification = AppNotification(
        id: 'notification-1',
        recipientId: '  user-2  ',
        projectId: '  project-1  ',
        type: NotificationType.postCreated,
        actorId: '  user-1  ',
        entityType: NotificationEntityType.post,
        entityId: '  post-1  ',
        message: '  Nova publicação no projeto.  ',
        createdAt: now.subtract(const Duration(minutes: 5)),
      );

      when(
            () => notificationRepository.createNotification(any()),
      ).thenAnswer((invocation) async {
        final receivedNotification =
        invocation.positionalArguments.first as AppNotification;

        expect(receivedNotification.id, 'notification-1');
        expect(receivedNotification.recipientId, 'user-2');
        expect(receivedNotification.projectId, 'project-1');
        expect(receivedNotification.actorId, 'user-1');
        expect(receivedNotification.entityId, 'post-1');
        expect(
          receivedNotification.message,
          'Nova publicação no projeto.',
        );
        expect(
          receivedNotification.type,
          NotificationType.postCreated,
        );
        expect(
          receivedNotification.entityType,
          NotificationEntityType.post,
        );
        expect(receivedNotification.createdAt, now);
        expect(receivedNotification.readAt, isNull);
        expect(receivedNotification.isRead, isFalse);

        return 'notification-1';
      });

      final result = await createNotification(
        notification,
        now: now,
      );

      expect(result, 'notification-1');

      verify(
            () => notificationRepository.createNotification(any()),
      ).called(1);
    });

    test('não deve persistir notificação com dados inválidos', () async {
      final now = DateTime(2026, 11, 2, 12);

      final notification = AppNotification(
        id: 'notification-2',
        recipientId: 'user-2',
        projectId: 'project-1',
        type: NotificationType.postCreated,
        actorId: 'user-1',
        entityType: NotificationEntityType.post,
        entityId: 'post-1',
        message: '   ',
        createdAt: now,
      );

      expect(
            () => createNotification(
          notification,
          now: now,
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => notificationRepository.createNotification(any()),
      );
    });
  });
}