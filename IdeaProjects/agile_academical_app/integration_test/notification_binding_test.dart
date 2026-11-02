
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:agile_academical_app/core/bindings/app_binding.dart';
import 'package:agile_academical_app/data/datasources/notification_firestore_datasource.dart';
import 'package:agile_academical_app/data/repositories/notification_repository_impl.dart';
import 'package:agile_academical_app/domain/repositories/notification_repository.dart';
import 'package:agile_academical_app/domain/usecases/notifications/create_notification.dart';
import 'package:agile_academical_app/domain/usecases/notifications/get_notification.dart';
import 'package:agile_academical_app/domain/usecases/notifications/get_notifications_for_user.dart';
import 'package:agile_academical_app/domain/usecases/notifications/get_unread_notifications_for_user.dart';
import 'package:agile_academical_app/domain/usecases/notifications/mark_notification_as_read.dart';
import 'package:agile_academical_app/domain/usecases/notifications/delete_notification.dart';
import 'package:agile_academical_app/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/.env');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    Get.reset();
    AppBinding().dependencies();
  });

  testWidgets(
    'deve resolver dependências do módulo Notification pelo AppBinding',
        (tester) async {
      // Use cases
      expect(
        Get.find<CreateNotification>(),
        isA<CreateNotification>(),
      );

      expect(
        Get.find<GetNotification>(),
        isA<GetNotification>(),
      );

      expect(
        Get.find<GetNotificationsForUser>(),
        isA<GetNotificationsForUser>(),
      );

      expect(
        Get.find<GetUnreadNotificationsForUser>(),
        isA<GetUnreadNotificationsForUser>(),
      );

      expect(
        Get.find<MarkNotificationAsRead>(),
        isA<MarkNotificationAsRead>(),
      );

      expect(
        Get.find<DeleteNotification>(),
        isA<DeleteNotification>(),
      );

      // Repository
      expect(
        Get.find<NotificationRepository>(),
        isA<NotificationRepositoryImpl>(),
      );

      // Data source
      expect(
        Get.find<NotificationFirestoreDataSource>(),
        isA<NotificationFirestoreDataSource>(),
      );
    },
  );
}
