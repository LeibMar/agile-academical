
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/app_notification.dart';
import 'package:agile_academical_app/domain/repositories/notification_repository.dart';
import 'package:agile_academical_app/domain/usecases/notifications/mark_notification_as_read.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class FakeAppNotification extends Fake implements AppNotification {}

void main() {
  late MockNotificationRepository repository;
  late MarkNotificationAsRead useCase;

  final createdAt = DateTime(2026, 11, 1, 9);
  final readAt = DateTime(2026, 11, 2, 10);

  AppNotification makeNotification({
    String id = 'notification-1',
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
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

  setUpAll(() {
    registerFallbackValue(FakeAppNotification());
  });

  setUp(() {
    repository = MockNotificationRepository();
    useCase = MarkNotificationAsRead(
      notificationRepository: repository,
    );
  });

  group('MarkNotificationAsRead', () {
    test('deve marcar uma notificação não lida como lida', () async {
      final notification = makeNotification();

      when(
            () => repository.getNotification('user-1', 'notification-1'),
      ).thenAnswer((_) async => notification);

      when(
            () => repository.updateNotification(any()),
      ).thenAnswer((_) async {});

      await useCase(
        userId: 'user-1',
        notificationId: 'notification-1',
        now: readAt,
      );

      final captured = verify(
            () => repository.updateNotification(captureAny()),
      ).captured.single as AppNotification;

      expect(captured.id, notification.id);
      expect(captured.recipientId, notification.recipientId);
      expect(captured.projectId, notification.projectId);
      expect(captured.type, notification.type);
      expect(captured.actorId, notification.actorId);
      expect(captured.entityType, notification.entityType);
      expect(captured.entityId, notification.entityId);
      expect(captured.message, notification.message);
      expect(captured.createdAt, createdAt);
      expect(captured.readAt, readAt);
      expect(captured.isRead, isTrue);
    });


    test('deve utilizar a data atual quando now não for informado', () async {
      final notification = makeNotification();

      when(
            () => repository.getNotification('user-1', 'notification-1'),
      ).thenAnswer((_) async => notification);

      when(
            () => repository.updateNotification(any()),
      ).thenAnswer((_) async {});

      await useCase(
        userId: 'user-1',
        notificationId: 'notification-1',
      );

      final captured = verify(
            () => repository.updateNotification(captureAny()),
      ).captured.single as AppNotification;

      expect(captured.readAt, isNotNull);
      expect(captured.isRead, isTrue);
      expect(captured.createdAt, createdAt);
    });


    test('não deve atualizar uma notificação que já foi lida', () async {
      final notification = makeNotification(readAt: readAt);

      when(
            () => repository.getNotification('user-1', 'notification-1'),
      ).thenAnswer((_) async => notification);

      await useCase(
        userId: 'user-1',
        notificationId: 'notification-1',
      );

      verifyNever(
            () => repository.updateNotification(any()),
      );
    });

    test('deve lançar StateError quando a notificação não existir', () async {
      when(
            () => repository.getNotification('user-1', 'notification-1'),
      ).thenAnswer((_) async => null);

      expect(
            () => useCase(
          userId: 'user-1',
          notificationId: 'notification-1',
        ),
        throwsA(isA<StateError>()),
      );

      verifyNever(
            () => repository.updateNotification(any()),
      );
    });

    test('deve rejeitar um ID de usuário vazio', () async {
      expect(
            () => useCase(
          userId: '',
          notificationId: 'notification-1',
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(
            () => repository.getNotification(any(), any()),
      );
    });

    test('deve rejeitar um ID de notificação vazio', () async {
      expect(
            () => useCase(
          userId: 'user-1',
          notificationId: '',
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(
            () => repository.getNotification(any(), any()),
      );
    });
  });
}
