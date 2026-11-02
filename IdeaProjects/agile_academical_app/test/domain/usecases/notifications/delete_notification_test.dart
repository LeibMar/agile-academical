
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/repositories/notification_repository.dart';
import 'package:agile_academical_app/domain/usecases/notifications/delete_notification.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late DeleteNotification useCase;

  setUp(() {
    repository = MockNotificationRepository();
    useCase = DeleteNotification(
      notificationRepository: repository,
    );
  });

  group('DeleteNotification', () {
    test('deve excluir uma notificação do usuário', () async {
      when(
            () => repository.deleteNotification(
          'user-1',
          'notification-1',
        ),
      ).thenAnswer((_) async {});

      await useCase(
        userId: 'user-1',
        notificationId: 'notification-1',
      );

      verify(
            () => repository.deleteNotification(
          'user-1',
          'notification-1',
        ),
      ).called(1);
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
            () => repository.deleteNotification(any(), any()),
      );
    });

    test('deve rejeitar um ID de usuário contendo apenas espaços',
            () async {
          expect(
                () => useCase(
              userId: '   ',
              notificationId: 'notification-1',
            ),
            throwsA(isA<ArgumentError>()),
          );

          verifyNever(
                () => repository.deleteNotification(any(), any()),
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
            () => repository.deleteNotification(any(), any()),
      );
    });

    test('deve rejeitar um ID de notificação contendo apenas espaços',
            () async {
          expect(
                () => useCase(
              userId: 'user-1',
              notificationId: '   ',
            ),
            throwsA(isA<ArgumentError>()),
          );

          verifyNever(
                () => repository.deleteNotification(any(), any()),
          );
        });
  });
}
