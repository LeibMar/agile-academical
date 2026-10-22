
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:agile_academical_app/core/bindings/app_binding.dart';
import 'package:agile_academical_app/data/datasources/comment_firestore_datasource.dart';
import 'package:agile_academical_app/data/repositories/comment_repository_impl.dart';
import 'package:agile_academical_app/domain/repositories/comment_repository.dart';
import 'package:agile_academical_app/domain/usecases/comments/create_comment.dart';
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
    'deve resolver CreateComment pelo AppBinding',
        (tester) async {
      final createComment = Get.find<CreateComment>();

      expect(createComment, isA<CreateComment>());

      expect(
        Get.find<CommentRepository>(),
        isA<CommentRepositoryImpl>(),
      );

      expect(
        Get.find<CommentFirestoreDataSource>(),
        isA<CommentFirestoreDataSource>(),
      );
    },
  );
}
