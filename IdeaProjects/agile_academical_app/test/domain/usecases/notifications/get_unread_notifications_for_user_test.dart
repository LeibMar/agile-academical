
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/app_notification.dart';
import 'package:agile_academical_app/domain/repositories/notification_repository.dart';
import 'package:agile_academical_app/domain/usecases/notifications/get_unread_notifications_for_user.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late GetUnreadNotificationsForUser useCase;

  setUp(() {
    repository = MockNotificationRepository();
    useCase = GetUnreadNotificationsForUser(
      notificationRepository: repository,
    );
  });

  AppNotification makeNotification({
    required String id,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      recipientId: 'user-1',
      projectId: 'project-1',
      type: NotificationType.postCreated,
      actorId: 'user-2',
      entityType: NotificationEntityType.post,
      entityId: 'post-$id',
      message: 'Uma nova publicação foi criada.',
      createdAt: DateTime(2026, 11, 2, 10),
      readAt: readAt,
    );
  }

  group('GetUnreadNotificationsForUser', () {
    test('deve retornar as notificações não lidas do usuário', () async {
      final notifications = [
        makeNotification(id: 'notification-1'),
        makeNotification(id: 'notification-2'),
      ];

      when(
            () => repository.getUnreadNotificationsForUser('user-1'),
      ).thenAnswer((_) async => notifications);

      final result = await useCase('user-1');

      expect(result, hasLength(2));
      expect(result[0].id, 'notification-1');
      expect(result[1].id, 'notification-2');
      expect(result.every((notification) => !notification.isRead), isTrue);

      verify(
            () => repository.getUnreadNotificationsForUser('user-1'),
      ).called(1);
    });

    test('deve retornar uma lista vazia quando não houver notificações não lidas',
            () async {
          when(
                () => repository.getUnreadNotificationsForUser('user-1'),
          ).thenAnswer((_) async => []);

          final result = await useCase('user-1');

          expect(result, isEmpty);

          verify(
                () => repository.getUnreadNotificationsForUser('user-1'),
          ).called(1);
        });

    test('deve rejeitar um ID de usuário vazio', () async {
      expect(
            () => useCase(''),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(
            () => repository.getUnreadNotificationsForUser(any()),
      );
    });

    test('deve rejeitar um ID de usuário contendo apenas espaços',
            () async {
          expect(
                () => useCase('   '),
            throwsA(isA<ArgumentError>()),
          );

          verifyNever(
                () => repository.getUnreadNotificationsForUser(any()),
          );
        });
  });
}
