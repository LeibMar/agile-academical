import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/app_notification.dart';
import 'package:agile_academical_app/domain/repositories/notification_repository.dart';
import 'package:agile_academical_app/domain/usecases/notifications/get_notification.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository notificationRepository;
  late GetNotification getNotification;

  setUp(() {
    notificationRepository = MockNotificationRepository();

    getNotification = GetNotification(
      notificationRepository: notificationRepository,
    );
  });

  group('GetNotification', () {
    final now = DateTime(2026, 11, 2, 12);

    final notification = AppNotification(
      id: 'notification-1',
      recipientId: 'user-2',
      projectId: 'project-1',
      type: NotificationType.postCreated,
      actorId: 'user-1',
      entityType: NotificationEntityType.post,
      entityId: 'post-1',
      message: 'Nova publicação no projeto.',
      createdAt: now,
    );

    test('deve retornar a notificação encontrada', () async {
      when(
            () => notificationRepository.getNotification(
          'user-2',
          'notification-1',
        ),
      ).thenAnswer((_) async => notification);

      final result = await getNotification(
        userId: 'user-2',
        notificationId: 'notification-1',
      );

      expect(result, isNotNull);
      expect(result!.id, 'notification-1');
      expect(result.recipientId, 'user-2');
      expect(result.projectId, 'project-1');
      expect(result.type, NotificationType.postCreated);

      verify(
            () => notificationRepository.getNotification(
          'user-2',
          'notification-1',
        ),
      ).called(1);
    });

    test('deve retornar null quando a notificação não existir', () async {
      when(
            () => notificationRepository.getNotification(
          'user-2',
          'notification-inexistente',
        ),
      ).thenAnswer((_) async => null);

      final result = await getNotification(
        userId: 'user-2',
        notificationId: 'notification-inexistente',
      );

      expect(result, isNull);

      verify(
            () => notificationRepository.getNotification(
          'user-2',
          'notification-inexistente',
        ),
      ).called(1);
    });

    test('deve rejeitar ID de usuário vazio', () async {
      await expectLater(
        getNotification(
          userId: '  ',
          notificationId: 'notification-1',
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => notificationRepository.getNotification(
          any(),
          any(),
        ),
      );
    });

    test('deve rejeitar ID de notificação vazio', () async {
      await expectLater(
        getNotification(
          userId: 'user-2',
          notificationId: '  ',
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => notificationRepository.getNotification(
          any(),
          any(),
        ),
      );
    });
  });
}