import 'package:get/get.dart';

import '../../data/datasources/project_firestore_datasource.dart';
import '../../data/datasources/stage_firestore_datasource.dart';
import '../../data/datasources/user_auth_datasource.dart';
import '../../data/datasources/user_firestore_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/repositories/stage_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/stage_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/users/register_user.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserAuthDataSource>(
          () => UserAuthDataSource(),
      fenix: true,
    );


    Get.lazyPut<UserFirestoreDataSource>(
    () => UserFirestoreDataSource(),
    fenix: true,
    );

    Get.lazyPut<ProjectFirestoreDataSource>(
    () => ProjectFirestoreDataSource(),
    fenix: true,
    );

    Get.lazyPut<StageFirestoreDataSource>(
    () => StageFirestoreDataSource(),
    fenix: true,
    );

    Get.lazyPut<AuthRepository>(
    () => AuthRepositoryImpl(
    dataSource: Get.find<UserAuthDataSource>(),
    ),
    fenix: true,
    );

    Get.lazyPut<UserRepository>(
    () => UserRepositoryImpl(
    firestoreDataSource: Get.find<UserFirestoreDataSource>(),
    authDataSource: Get.find<UserAuthDataSource>(),
    ),
    fenix: true,
    );

    Get.lazyPut<RegisterUser>(
    () => RegisterUser(
    authRepository: Get.find<AuthRepository>(),
    userRepository: Get.find<UserRepository>(),
    ),
    fenix: true,
    );

    Get.lazyPut<ProjectRepository>(
    () => ProjectRepositoryImpl(
    dataSource: Get.find<ProjectFirestoreDataSource>(),
    ),
    fenix: true,
    );

    Get.lazyPut<StageRepository>(
    () => StageRepositoryImpl(
    dataSource: Get.find<StageFirestoreDataSource>(),
    ),
    fenix: true,
    );


  }
}
