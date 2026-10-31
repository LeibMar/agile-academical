
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/project.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/project_repository.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late RegisterUser registerUser;
  late ProjectRepository projectRepository;
  late UserAuthDataSource authDataSource;
  late FirebaseFirestore firestore;

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/.env');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppBinding().dependencies();

    registerUser = Get.find<RegisterUser>();
    projectRepository = Get.find<ProjectRepository>();
    authDataSource = Get.find<UserAuthDataSource>();
    firestore = FirebaseFirestore.instance;
  });

  testWidgets(
    'deve excluir projeto e todas as suas subcoleções',
        (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final email = 'delete.project.$timestamp@agileacademical.com';
      const password = 'Teste@123456';

      // ============================================================
      // PREPARAÇÃO: CRIA USUÁRIO E PROJETO
      // ============================================================

      final user = await registerUser.call(
        name: 'Usuário de Exclusão',
        email: email,
        password: password,
        role: UserRole.student,
      );

      expect(user.uid, isNotEmpty);

      final project = Project(
        id: '',
        title: 'Projeto para Exclusão Recursiva',
        description: 'Projeto criado para testar a exclusão completa.',
        status: ProjectStatus.planning,
        ownerId: user.uid,
        advisorId: null,
        memberIds: [user.uid],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final projectId = await projectRepository.createProject(project);

      expect(projectId, isNotEmpty);

      final projectReference = firestore
          .collection('projects')
          .doc(projectId);

      // ============================================================
      // CRIAÇÃO DAS SUBCOLEÇÕES
      // ============================================================

      // Duas etapas.
      await projectReference.collection('stages').doc('stage-1').set({
        'title': 'Planejamento',
        'order': 1,
      });

      await projectReference.collection('stages').doc('stage-2').set({
        'title': 'Desenvolvimento',
        'order': 2,
      });

      // Duas tarefas.
      await projectReference.collection('tasks').doc('task-1').set({
        'title': 'Definir requisitos',
        'status': 'todo',
      });

      await projectReference.collection('tasks').doc('task-2').set({
        'title': 'Implementar funcionalidade',
        'status': 'inProgress',
      });

      // Duas publicações.
      final post1 = projectReference.collection('posts').doc('post-1');
      final post2 = projectReference.collection('posts').doc('post-2');

      await post1.set({
        'authorId': user.uid,
        'content': 'Primeira publicação de teste.',
      });

      await post2.set({
        'authorId': user.uid,
        'content': 'Segunda publicação de teste.',
      });

      // Dois comentários na primeira publicação.
      await post1.collection('comments').doc('comment-1').set({
        'authorId': user.uid,
        'content': 'Primeiro comentário.',
      });

      await post1.collection('comments').doc('comment-2').set({
        'authorId': user.uid,
        'content': 'Segundo comentário.',
      });

      // Um comentário na segunda publicação.
      await post2.collection('comments').doc('comment-3').set({
        'authorId': user.uid,
        'content': 'Terceiro comentário.',
      });

      // ============================================================
      // CONFIRMAÇÃO DA ESTRUTURA ANTES DA EXCLUSÃO
      // ============================================================

      expect(
        (await projectReference.collection('stages').get()).docs.length,
        2,
      );

      expect(
        (await projectReference.collection('tasks').get()).docs.length,
        2,
      );

      expect(
        (await projectReference.collection('posts').get()).docs.length,
        2,
      );

      expect(
        (await post1.collection('comments').get()).docs.length,
        2,
      );

      expect(
        (await post2.collection('comments').get()).docs.length,
        1,
      );

      // ============================================================
      // DELETE PROJECT
      // ============================================================

      await projectRepository.deleteProject(projectId);

      // ============================================================
      // VERIFICAÇÃO DA EXCLUSÃO
      // ============================================================

      // Documento principal.
      final deletedProject = await projectReference.get();

      expect(deletedProject.exists, isFalse);

      // Etapas.
      final remainingStages = await projectReference
          .collection('stages')
          .get();

      expect(remainingStages.docs, isEmpty);

      // Tarefas.
      final remainingTasks = await projectReference
          .collection('tasks')
          .get();

      expect(remainingTasks.docs, isEmpty);

      // Publicações.
      final remainingPosts = await projectReference
          .collection('posts')
          .get();

      expect(remainingPosts.docs, isEmpty);

      // Comentários da primeira publicação.
      final remainingCommentsPost1 = await post1
          .collection('comments')
          .get();

      expect(remainingCommentsPost1.docs, isEmpty);

      // Comentários da segunda publicação.
      final remainingCommentsPost2 = await post2
          .collection('comments')
          .get();

      expect(remainingCommentsPost2.docs, isEmpty);

      // ============================================================
      // LIMPEZA DO USUÁRIO DE TESTE
      // ============================================================

      await authDataSource.deleteCurrentUser();

      expect(
        authDataSource.currentUser,
        isNull,
      );
    },
  );
}
