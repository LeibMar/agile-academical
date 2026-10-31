import 'package:get/get.dart';
import '../../domain/usecases/projects/create_project.dart';
import '../../domain/usecases/projects/get_project.dart';
import '../../domain/usecases/projects/get_projects_for_user.dart';
import '../../domain/usecases/projects/update_project.dart';
import '../../domain/usecases/projects/add_project_member.dart';
import '../../domain/usecases/projects/remove_project_member.dart';
import '../../domain/usecases/projects/cancel_project.dart';
import '../../domain/usecases/projects/delete_project.dart';
import '../../data/datasources/project_firestore_datasource.dart';
import '../../data/datasources/stage_firestore_datasource.dart';
import '../../data/datasources/user_auth_datasource.dart';
import '../../data/datasources/user_firestore_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/task_firestore_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/tasks/create_task.dart';
import '../../domain/usecases/tasks/get_task.dart';
import '../../domain/usecases/tasks/get_tasks_for_project.dart';
import '../../domain/usecases/tasks/update_task.dart';
import '../../domain/usecases/tasks/delete_task.dart';
import '../../data/datasources/post_firestore_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/posts/create_post.dart';
import '../../domain/usecases/posts/get_post.dart';
import '../../domain/usecases/posts/get_posts_for_project.dart';
import '../../domain/usecases/posts/update_post.dart';
import '../../domain/usecases/posts/delete_post.dart';
import '../../data/datasources/comment_firestore_datasource.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/comments/create_comment.dart';
import '../../domain/usecases/comments/get_comment.dart';
import '../../domain/usecases/comments/get_comments_for_post.dart';
import '../../domain/usecases/comments/update_comment.dart';
import '../../domain/usecases/comments/delete_comment.dart';
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

    Get.lazyPut<TaskFirestoreDataSource>(
          () => TaskFirestoreDataSource(),
      fenix: true,
    );
    Get.lazyPut<PostFirestoreDataSource>(
          () => PostFirestoreDataSource(),
      fenix: true,
    );
    Get.lazyPut<CommentFirestoreDataSource>(
          () => CommentFirestoreDataSource(),
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
    Get.lazyPut<CreateProject>(
          () => CreateProject(Get.find<ProjectRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetProject>(
          () => GetProject(Get.find<ProjectRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetProjectsForUser>(
          () => GetProjectsForUser(Get.find<ProjectRepository>()),
      fenix: true,
    );

    Get.lazyPut<UpdateProject>(
          () => UpdateProject(Get.find<ProjectRepository>()),
      fenix: true,
    );

    Get.lazyPut<AddProjectMember>(
          () => AddProjectMember(Get.find<ProjectRepository>()),
      fenix: true,
    );

    Get.lazyPut<RemoveProjectMember>(
          () => RemoveProjectMember(Get.find<ProjectRepository>()),
      fenix: true,
    );

    Get.lazyPut<CancelProject>(
          () => CancelProject(Get.find<ProjectRepository>()),
      fenix: true,
    );

    Get.lazyPut<DeleteProject>(
          () => DeleteProject(Get.find<ProjectRepository>()),
      fenix: true,
    );
    Get.lazyPut<StageRepository>(
    () => StageRepositoryImpl(
    dataSource: Get.find<StageFirestoreDataSource>(),
    ),
    fenix: true,
    );
    Get.lazyPut<TaskRepository>(
          () => TaskRepositoryImpl(
        dataSource: Get.find<TaskFirestoreDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PostRepository>(
          () => PostRepositoryImpl(
        dataSource: Get.find<PostFirestoreDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CommentRepository>(
          () => CommentRepositoryImpl(
        dataSource: Get.find<CommentFirestoreDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetTask>(
          () => GetTask(Get.find<TaskRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetTasksForProject>(
          () => GetTasksForProject(Get.find<TaskRepository>()),
      fenix: true,
    );
    Get.lazyPut<UpdateTask>(
          () => UpdateTask(Get.find<TaskRepository>()),
      fenix: true,
    );
    Get.lazyPut<CreateTask>(
          () => CreateTask(
        taskRepository: Get.find<TaskRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeleteTask>(
          () => DeleteTask(Get.find<TaskRepository>()),
      fenix: true,
    );


    Get.lazyPut<CreatePost>(
          () => CreatePost(
        postRepository: Get.find<PostRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetPost>(
          () => GetPost(Get.find<PostRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetPostsForProject>(
          () => GetPostsForProject(Get.find<PostRepository>()),
      fenix: true,
    );

    Get.lazyPut<UpdatePost>(
          () => UpdatePost(Get.find<PostRepository>()),
      fenix: true,
    );

    Get.lazyPut<DeletePost>(
          () => DeletePost(Get.find<PostRepository>()),
      fenix: true,
    );

    Get.lazyPut<CreateComment>(
          () => CreateComment(
        Get.find<CommentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetComment>(
          () => GetComment(
        Get.find<CommentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetCommentsForPost>(
          () => GetCommentsForPost(
        Get.find<CommentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UpdateComment>(
          () => UpdateComment(
        Get.find<CommentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeleteComment>(
          () => DeleteComment(
        Get.find<CommentRepository>(),
      ),
      fenix: true,
    );


  }
}
