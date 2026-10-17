
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:agile_academical_app/core/bindings/app_binding.dart';
import 'package:agile_academical_app/domain/usecases/posts/update_post.dart';
import 'package:agile_academical_app/data/datasources/post_firestore_datasource.dart';
import 'package:agile_academical_app/domain/repositories/post_repository.dart';
import 'package:agile_academical_app/data/repositories/post_repository_impl.dart';
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
    'deve resolver UpdatePost pelo AppBinding',
        (tester) async {
      final updatePost = Get.find<UpdatePost>();

      expect(updatePost, isA<UpdatePost>());

      expect(
        Get.find<PostRepository>(),
        isA<PostRepositoryImpl>(),
      );

      expect(
        Get.find<PostFirestoreDataSource>(),
        isA<PostFirestoreDataSource>(),
      );
    },
  );
}
