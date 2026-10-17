
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/post.dart';
import '../lib/domain/entities/project.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/post_repository.dart';
import '../lib/domain/repositories/project_repository.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

    postRepository = Get.find<PostRepository>();
    projectRepository = Get.find<ProjectRepository>();
    registerUser = Get.find<RegisterUser>();
    authDataSource = Get.find<UserAuthDataSource>();
  });

  testWidgets(
    'deve realizar CRUD de publicações vinculadas a um projeto',
        (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userEmail = 'post.test.$timestamp@example.com';
      const userPassword = 'Test@123456';

      String? projectId;
      String? firstPostId;
      String? secondPostId;

      try {
        // 1. Cria usuário de teste.
        final registeredUser = await registerUser.call(
          name: 'Usuário Teste Post',
          email: userEmail,
          password: userPassword,
          role: UserRole.student,
        );

        expect(registeredUser.uid, isNotEmpty);

        // 2. Cria projeto de teste.
        final project = Project(
          id: '',
          title: 'Projeto Teste Post',
          description: 'Projeto utilizado no teste de publicações.',
          status: ProjectStatus.planning,
          ownerId: registeredUser.uid,
          advisorId: null,
          memberIds: [registeredUser.uid],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        projectId = await projectRepository.createProject(project);

        expect(projectId, isNotEmpty);

        // 3. Cria a primeira publicação.
        final firstPost = Post(
          id: '',
          projectId: projectId,
          authorId: registeredUser.uid,
          content: 'Publicação inicial do projeto.',
          attachmentUrls: const [
            'https://example.com/documento.pdf',
          ],
          youtubeUrl: 'https://www.youtube.com/watch?v=abcdefghijk',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        firstPostId = await postRepository.createPost(firstPost);

        expect(firstPostId, isNotEmpty);

        // 4. Cria uma segunda publicação.
        final secondPost = Post(
          id: '',
          projectId: projectId,
          authorId: registeredUser.uid,
          content: 'Atualização do andamento do projeto.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        secondPostId = await postRepository.createPost(secondPost);

        expect(secondPostId, isNotEmpty);
        expect(secondPostId, isNot(firstPostId));

        // 5. Busca a primeira publicação.
        final retrievedFirstPost = await postRepository.getPost(
          projectId,
          firstPostId,
        );

        expect(retrievedFirstPost, isNotNull);
        expect(retrievedFirstPost!.id, firstPostId);
        expect(retrievedFirstPost.projectId, projectId);
        expect(retrievedFirstPost.authorId, registeredUser.uid);
        expect(
          retrievedFirstPost.content,
          'Publicação inicial do projeto.',
        );
        expect(
          retrievedFirstPost.attachmentUrls,
          ['https://example.com/documento.pdf'],
        );
        expect(
          retrievedFirstPost.youtubeUrl,
          'https://www.youtube.com/watch?v=abcdefghijk',
        );
        expect(retrievedFirstPost.createdAt, isNotNull);
        expect(retrievedFirstPost.updatedAt, isNotNull);

        // 6. Lista as publicações do projeto.
        final posts = await postRepository.getPostsForProject(projectId);

        expect(posts.length, 2);
        expect(
          posts.map((post) => post.id),
          containsAll([firstPostId, secondPostId]),
        );
        expect(
          posts.every((post) => post.projectId == projectId),
          isTrue,
        );

        // 7. Atualiza a segunda publicação.
        final updatedSecondPost = Post(
          id: secondPostId,
          projectId: projectId,
          authorId: registeredUser.uid,
          content: 'Andamento atualizado: requisitos concluídos.',
          attachmentUrls: const [
            'https://example.com/requisitos.pdf',
          ],
          youtubeUrl: null,
          createdAt: secondPost.createdAt,
          updatedAt: DateTime.now(),
        );

        await postRepository.updatePost(updatedSecondPost);

        // 8. Confirma a atualização.
        final retrievedUpdatedPost = await postRepository.getPost(
          projectId,
          secondPostId,
        );

        expect(retrievedUpdatedPost, isNotNull);
        expect(
          retrievedUpdatedPost!.content,
          'Andamento atualizado: requisitos concluídos.',
        );
        expect(
          retrievedUpdatedPost.attachmentUrls,
          ['https://example.com/requisitos.pdf'],
        );
        expect(retrievedUpdatedPost.youtubeUrl, isNull);
        expect(retrievedUpdatedPost.authorId, registeredUser.uid);
        expect(retrievedUpdatedPost.createdAt, isNotNull);
        expect(retrievedUpdatedPost.updatedAt, isNotNull);

        // 9. Exclui a primeira publicação.
        await postRepository.deletePost(projectId, firstPostId);

        final deletedPost = await postRepository.getPost(
          projectId,
          firstPostId,
        );

        expect(deletedPost, isNull);

        // 10. Confirma que a segunda publicação continua existindo.
        final remainingPosts =
        await postRepository.getPostsForProject(projectId);

        expect(remainingPosts.length, 1);
        expect(remainingPosts.single.id, secondPostId);

        // 11. Exclui a segunda publicação.
        await postRepository.deletePost(projectId, secondPostId);

        final postsAfterDeletion =
        await postRepository.getPostsForProject(projectId);

        expect(postsAfterDeletion, isEmpty);

        // 12. Exclui o projeto de teste.
        await projectRepository.deleteProject(projectId);

        final deletedProject =
        await projectRepository.getProject(projectId);

        expect(deletedProject, isNull);

        projectId = null;
        firstPostId = null;
        secondPostId = null;
      } finally {
        // Limpeza caso alguma etapa do teste falhe.
        if (projectId != null) {
          if (firstPostId != null) {
            await postRepository.deletePost(projectId, firstPostId);
          }

          if (secondPostId != null) {
            await postRepository.deletePost(projectId, secondPostId);
          }

          await projectRepository.deleteProject(projectId);
        }

        await authDataSource.deleteCurrentUser();
      }
    },
  );
}
