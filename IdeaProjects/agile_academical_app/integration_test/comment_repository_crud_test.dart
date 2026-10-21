import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/comment.dart';
import '../lib/domain/entities/post.dart';
import '../lib/domain/entities/project.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/comment_repository.dart';
import '../lib/domain/repositories/post_repository.dart';
import '../lib/domain/repositories/project_repository.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late CommentRepository commentRepository;
  late PostRepository postRepository;
  late ProjectRepository projectRepository;
  late RegisterUser registerUser;
  late UserAuthDataSource authDataSource;

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/.env');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppBinding().dependencies();

    commentRepository = Get.find<CommentRepository>();
    postRepository = Get.find<PostRepository>();
    projectRepository = Get.find<ProjectRepository>();
    registerUser = Get.find<RegisterUser>();
    authDataSource = Get.find<UserAuthDataSource>();
  });

  testWidgets(
    'deve realizar CRUD de comentários vinculados a uma publicação',
        (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userEmail = 'comment.test.$timestamp@example.com';
      const userPassword = 'Test@123456';

      String? projectId;
      String? postId;
      String? firstCommentId;
      String? secondCommentId;

      try {
        // 1. Cria o usuário de teste.
        final registeredUser = await registerUser.call(
          name: 'Usuário Teste Comment',
          email: userEmail,
          password: userPassword,
          role: UserRole.student,
        );

        expect(registeredUser.uid, isNotEmpty);

        // 2. Cria o projeto de teste.
        final project = Project(
          id: '',
          title: 'Projeto Teste Comment',
          description: 'Projeto utilizado no teste de comentários.',
          status: ProjectStatus.planning,
          ownerId: registeredUser.uid,
          advisorId: null,
          memberIds: [registeredUser.uid],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        projectId = await projectRepository.createProject(project);

        expect(projectId, isNotEmpty);

        // 3. Cria uma publicação no projeto.
        final post = Post(
          id: '',
          projectId: projectId,
          authorId: registeredUser.uid,
          content: 'Publicação para teste de comentários.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        postId = await postRepository.createPost(post);

        expect(postId, isNotEmpty);

        // 4. Cria o primeiro comentário.
        final firstComment = Comment(
          id: '',
          projectId: projectId,
          postId: postId,
          authorId: registeredUser.uid,
          content: 'Primeiro comentário.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        firstCommentId =
        await commentRepository.createComment(firstComment);

        expect(firstCommentId, isNotEmpty);

        // 5. Cria um segundo comentário.
        final secondComment = Comment(
          id: '',
          projectId: projectId,
          postId: postId,
          authorId: registeredUser.uid,
          content: 'Segundo comentário.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        secondCommentId =
        await commentRepository.createComment(secondComment);

        expect(secondCommentId, isNotEmpty);
        expect(secondCommentId, isNot(firstCommentId));

        // 6. Recupera o primeiro comentário.
        final retrievedComment = await commentRepository.getComment(
          projectId,
          postId,
          firstCommentId,
        );

        expect(retrievedComment, isNotNull);
        expect(retrievedComment!.id, firstCommentId);
        expect(retrievedComment.projectId, projectId);
        expect(retrievedComment.postId, postId);
        expect(retrievedComment.authorId, registeredUser.uid);
        expect(retrievedComment.content, 'Primeiro comentário.');
        expect(retrievedComment.createdAt, isNotNull);
        expect(retrievedComment.updatedAt, isNotNull);

        // 7. Lista os comentários da publicação.
        final comments = await commentRepository.getCommentsForPost(
          projectId,
          postId,
        );

        expect(comments, hasLength(2));
        expect(
          comments.map((comment) => comment.id),
          containsAll([firstCommentId, secondCommentId]),
        );
        expect(
          comments.every(
                (comment) =>
            comment.projectId == projectId &&
                comment.postId == postId,
          ),
          isTrue,
        );

        // 8. Atualiza o segundo comentário.
        final updatedComment = Comment(
          id: secondCommentId,
          projectId: projectId,
          postId: postId,
          authorId: registeredUser.uid,
          content: 'Segundo comentário atualizado.',
          createdAt: secondComment.createdAt,
          updatedAt: DateTime.now(),
        );

        await commentRepository.updateComment(updatedComment);

        // 9. Confirma a atualização.
        final retrievedUpdatedComment =
        await commentRepository.getComment(
          projectId,
          postId,
          secondCommentId,
        );

        expect(retrievedUpdatedComment, isNotNull);
        expect(
          retrievedUpdatedComment!.content,
          'Segundo comentário atualizado.',
        );
        expect(retrievedUpdatedComment.authorId, registeredUser.uid);
        expect(retrievedUpdatedComment.createdAt, isNotNull);
        expect(retrievedUpdatedComment.updatedAt, isNotNull);

        // 10. Exclui o primeiro comentário.
        await commentRepository.deleteComment(
          projectId,
          postId,
          firstCommentId,
        );

        final deletedComment = await commentRepository.getComment(
          projectId,
          postId,
          firstCommentId,
        );

        expect(deletedComment, isNull);

        // 11. Confirma que o segundo comentário continua existindo.
        final remainingComments =
        await commentRepository.getCommentsForPost(
          projectId,
          postId,
        );

        expect(remainingComments, hasLength(1));
        expect(remainingComments.single.id, secondCommentId);

        // 12. Exclui o segundo comentário.
        await commentRepository.deleteComment(
          projectId,
          postId,
          secondCommentId,
        );

        final commentsAfterDeletion =
        await commentRepository.getCommentsForPost(
          projectId,
          postId,
        );

        expect(commentsAfterDeletion, isEmpty);

        // 13. Confirma que a publicação continua existindo.
        final existingPost = await postRepository.getPost(
          projectId,
          postId,
        );

        expect(existingPost, isNotNull);
        expect(existingPost!.id, postId);

      } finally {
        // Limpa primeiro os comentários, pois o Firestore não
        // exclui automaticamente subcoleções ao excluir um documento.
        if (projectId != null && postId != null) {
          if (firstCommentId != null) {
            await commentRepository.deleteComment(
              projectId,
              postId,
              firstCommentId,
            );
          }

          if (secondCommentId != null) {
            await commentRepository.deleteComment(
              projectId,
              postId,
              secondCommentId,
            );
          }

          await postRepository.deletePost(projectId, postId);
        }

        if (projectId != null) {
          await projectRepository.deleteProject(projectId);
        }

        await authDataSource.deleteCurrentUser();
      }
    },
  );
}