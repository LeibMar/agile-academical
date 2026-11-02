
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/app_notification.dart';
import '../lib/domain/entities/project.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/notification_repository.dart';
import '../lib/domain/repositories/project_repository.dart';
import '../lib/domain/usecases/notifications/mark_notification_as_read.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late NotificationRepository notificationRepository;
  late ProjectRepository projectRepository;
  late RegisterUser registerUser;
  late MarkNotificationAsRead markNotificationAsRead;
  late UserAuthDataSource authDataSource;

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/.env');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppBinding().dependencies();

    notificationRepository = Get.find<NotificationRepository>();
    projectRepository = Get.find<ProjectRepository>();
    registerUser = Get.find<RegisterUser>();
    markNotificationAsRead = Get.find<MarkNotificationAsRead>();
    authDataSource = Get.find<UserAuthDataSource>();
  });

  testWidgets(
    'deve realizar CRUD de notificações de um usuário',
        (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userEmail = 'notification.test.$timestamp@example.com';
      const userPassword = 'Test@123456';

      String? projectId;
      String? firstNotificationId;
      String? secondNotificationId;

      try {
        // 1. Cria o usuário de teste.
        final registeredUser = await registerUser.call(
          name: 'Usuário Teste Notification',
          email: userEmail,
          password: userPassword,
          role: UserRole.student,
        );

        expect(registeredUser.uid, isNotEmpty);

        // 2. Cria um projeto para vincular às notificações.
        final project = Project(
          id: '',
          title: 'Projeto Teste Notification',
          description: 'Projeto utilizado no teste de notificações.',
          status: ProjectStatus.planning,
          ownerId: registeredUser.uid,
          advisorId: null,
          memberIds: [registeredUser.uid],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        projectId = await projectRepository.createProject(project);

        expect(projectId, isNotEmpty);

        // 3. Cria a primeira notificação.
        final firstNotification = AppNotification(
          id: '',
          recipientId: registeredUser.uid,
          projectId: projectId,
          type: NotificationType.mention,
          actorId: registeredUser.uid,
          entityType: NotificationEntityType.post,
          entityId: 'post-teste-1',
          message: 'Você foi mencionado em uma publicação.',
          createdAt: DateTime.now(),
        );

        firstNotificationId =
        await notificationRepository.createNotification(
          firstNotification,
        );

        expect(firstNotificationId, isNotEmpty);

        // 4. Cria uma segunda notificação.
        final secondNotification = AppNotification(
          id: '',
          recipientId: registeredUser.uid,
          projectId: projectId,
          type: NotificationType.taskAssigned,
          actorId: registeredUser.uid,
          entityType: NotificationEntityType.task,
          entityId: 'task-teste-1',
          message: 'Uma tarefa foi atribuída a você.',
          createdAt: DateTime.now(),
        );

        secondNotificationId =
        await notificationRepository.createNotification(
          secondNotification,
        );

        expect(secondNotificationId, isNotEmpty);
        expect(secondNotificationId, isNot(firstNotificationId));

        // 5. Recupera a primeira notificação.
        final retrievedNotification =
        await notificationRepository.getNotification(
          registeredUser.uid,
          firstNotificationId,
        );

        expect(retrievedNotification, isNotNull);
        expect(retrievedNotification!.id, firstNotificationId);
        expect(retrievedNotification.recipientId, registeredUser.uid);
        expect(retrievedNotification.projectId, projectId);
        expect(retrievedNotification.type, NotificationType.mention);
        expect(retrievedNotification.actorId, registeredUser.uid);
        expect(
          retrievedNotification.entityType,
          NotificationEntityType.post,
        );
        expect(retrievedNotification.entityId, 'post-teste-1');
        expect(
          retrievedNotification.message,
          'Você foi mencionado em uma publicação.',
        );
        expect(retrievedNotification.createdAt, isNotNull);
        expect(retrievedNotification.readAt, isNull);
        expect(retrievedNotification.isRead, isFalse);

        // 6. Lista todas as notificações do usuário.
        final notifications =
        await notificationRepository.getNotificationsForUser(
          registeredUser.uid,
        );

        expect(notifications, hasLength(2));
        expect(
          notifications.map((notification) => notification.id),
          containsAll([firstNotificationId, secondNotificationId]),
        );

        expect(
          notifications.every(
                (notification) =>
            notification.recipientId == registeredUser.uid,
          ),
          isTrue,
        );

        // 7. Lista somente as notificações não lidas.
        final unreadNotifications =
        await notificationRepository.getUnreadNotificationsForUser(
          registeredUser.uid,
        );

        expect(unreadNotifications, hasLength(2));
        expect(
          unreadNotifications.every(
                (notification) => notification.isRead == false,
          ),
          isTrue,
        );

        // 8. Marca a primeira notificação como lida.
        await markNotificationAsRead.call(
          userId: registeredUser.uid,
          notificationId: firstNotificationId,
        );

        // 9. Confirma que a primeira notificação foi marcada como lida.
        final readNotification =
        await notificationRepository.getNotification(
          registeredUser.uid,
          firstNotificationId,
        );

        expect(readNotification, isNotNull);
        expect(readNotification!.isRead, isTrue);
        expect(readNotification.readAt, isNotNull);

        // 10. Confirma que a segunda notificação continua não lida.
        final unreadNotification =
        await notificationRepository.getNotification(
          registeredUser.uid,
          secondNotificationId,
        );

        expect(unreadNotification, isNotNull);
        expect(unreadNotification!.isRead, isFalse);
        expect(unreadNotification.readAt, isNull);

        // 11. Confirma a listagem atualizada de não lidas.
        final remainingUnreadNotifications =
        await notificationRepository.getUnreadNotificationsForUser(
          registeredUser.uid,
        );

        expect(remainingUnreadNotifications, hasLength(1));
        expect(
          remainingUnreadNotifications.single.id,
          secondNotificationId,
        );

        // 12. Exclui a primeira notificação.
        await notificationRepository.deleteNotification(
          registeredUser.uid,
          firstNotificationId,
        );

        final deletedNotification =
        await notificationRepository.getNotification(
          registeredUser.uid,
          firstNotificationId,
        );

        expect(deletedNotification, isNull);

        // 13. Confirma que a segunda notificação continua existindo.
        final remainingNotifications =
        await notificationRepository.getNotificationsForUser(
          registeredUser.uid,
        );

        expect(remainingNotifications, hasLength(1));
        expect(remainingNotifications.single.id, secondNotificationId);

        // 14. Exclui a segunda notificação.
        await notificationRepository.deleteNotification(
          registeredUser.uid,
          secondNotificationId,
        );

        final notificationsAfterDeletion =
        await notificationRepository.getNotificationsForUser(
          registeredUser.uid,
        );

        expect(notificationsAfterDeletion, isEmpty);
      } finally {
        // 15. Limpa as notificações criadas durante o teste.
        if (firstNotificationId != null) {
          await notificationRepository.deleteNotification(
            // O usuário autenticado continua sendo o destinatário.
            // O ID é recuperado do usuário atual do Firebase Auth
            // por meio do documento associado às notificações.
            authDataSource.currentUser!.uid,
            firstNotificationId,
          );
        }

        if (secondNotificationId != null) {
          await notificationRepository.deleteNotification(
            authDataSource.currentUser!.uid,
            secondNotificationId,
          );
        }

        // 16. Exclui o projeto de teste.
        if (projectId != null) {
          await projectRepository.deleteProject(projectId);
        }

        // 17. Exclui o usuário de teste.
        await authDataSource.deleteCurrentUser();
      }
    },
  );
}
