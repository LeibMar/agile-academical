import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/app_notification.dart';
import 'package:agile_academical_app/domain/repositories/notification_repository.dart';
import 'package:agile_academical_app/domain/usecases/notifications/get_notifications_for_user.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository notificationRepository;
  late GetNotificationsForUser getNotificationsForUser;

  setUp(() {
    notificationRepository = MockNotificationRepository();

    getNotificationsForUser = GetNotificationsForUser(
      notificationRepository: notificationRepository,
    );
  });

  group('GetNotificationsForUser', () {
    final now = DateTime(2026, 11, 2, 12);

    final notifications = [
      AppNotification(
        id: 'notification-1',
        recipientId: 'user-1',
        projectId: 'project-1',
        type: NotificationType.postCreated,
        actorId: 'user-2',
        entityType: NotificationEntityType.post,
        entityId: 'post-1',
        message: 'Nova publicação no projeto.',
        createdAt: now,
      ),
      AppNotification(
        id: 'notification-2',
        recipientId: 'user-1',
        projectId: 'project-1',
        type: NotificationType.commentCreated,
        actorId: 'user-3',
        entityType: NotificationEntityType.comment,
        entityId: 'comment-1',
        message: 'Novo comentário na publicação.',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];

    test('deve retornar todas as notificações do usuário', () async {
      when(
            () => notificationRepository.getNotificationsForUser('user-1'),
      ).thenAnswer((_) async => notifications);

      final result = await getNotificationsForUser('user-1');

      expect(result, hasLength(2));
      expect(result[0].id, 'notification-1');
      expect(result[1].id, 'notification-2');
      expect(result.every((item) => item.recipientId == 'user-1'), isTrue);

      verify(
            () => notificationRepository.getNotificationsForUser('user-1'),
      ).called(1);
    });

    test('deve retornar lista vazia quando não houver notificações', () async {
      when(
            () => notificationRepository.getNotificationsForUser('user-1'),
      ).thenAnswer((_) async => []);

      final result = await getNotificationsForUser('user-1');

      expect(result, isEmpty);

      verify(
            () => notificationRepository.getNotificationsForUser('user-1'),
      ).called(1);
    });

    test('deve rejeitar ID de usuário vazio', () async {
      await expectLater(
        getNotificationsForUser('  '),
        throwsArgumentError,
      );

      verifyNever(
            () => notificationRepository.getNotificationsForUser(any()),
      );
    });
  });
}