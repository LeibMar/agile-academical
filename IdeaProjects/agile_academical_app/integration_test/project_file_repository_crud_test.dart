import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/bindings/app_binding.dart';
import '../lib/data/datasources/user_auth_datasource.dart';
import '../lib/domain/entities/project.dart';
import '../lib/domain/entities/project_file.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/repositories/project_file_repository.dart';
import '../lib/domain/repositories/project_repository.dart';
import '../lib/domain/usecases/users/register_user.dart';
import '../lib/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProjectFileRepository projectFileRepository;
  late ProjectRepository projectRepository;
  late RegisterUser registerUser;
  late UserAuthDataSource authDataSource;

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/.env');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppBinding().dependencies();

    projectFileRepository = Get.find<ProjectFileRepository>();
    projectRepository = Get.find<ProjectRepository>();
    registerUser = Get.find<RegisterUser>();
    authDataSource = Get.find<UserAuthDataSource>();
  });

  testWidgets(
    'deve realizar CRUD de arquivos vinculados a um projeto',
        (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userEmail = 'project.file.test.$timestamp@example.com';
      const userPassword = 'Test@123456';

      String? projectId;
      String? firstFileId;
      String? secondFileId;

      try {
        // 1. Cria o usuário de teste.
        final registeredUser = await registerUser.call(
          name: 'Usuário Teste Project File',
          email: userEmail,
          password: userPassword,
          role: UserRole.student,
        );

        expect(registeredUser.uid, isNotEmpty);

        // 2. Cria o projeto de teste.
        final project = Project(
          id: '',
          title: 'Projeto Teste Project File',
          description: 'Projeto utilizado no teste de arquivos.',
          status: ProjectStatus.planning,
          ownerId: registeredUser.uid,
          advisorId: null,
          memberIds: [registeredUser.uid],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        projectId = await projectRepository.createProject(project);

        expect(projectId, isNotEmpty);

        // 3. Cria o primeiro arquivo: link externo.
        final firstFile = ProjectFile(
          id: '',
          projectId: projectId,
          name: 'Documentação externa',
          description: 'Link utilizado no teste.',
          sourceType: FileSourceType.externalLink,
          externalUrl: 'https://example.com/documentacao',
          uploadedBy: registeredUser.uid,
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: 'post-teste',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        firstFileId = await projectFileRepository.createFile(firstFile);

        expect(firstFileId, isNotEmpty);

        // 4. Cria o segundo arquivo: metadados de arquivo enviado.
        // Não ocorre upload real para o Firebase Storage.
        final secondFile = ProjectFile(
          id: '',
          projectId: projectId,
          name: 'Documento de teste.pdf',
          description: 'Metadados de um arquivo enviado.',
          sourceType: FileSourceType.uploaded,
          storagePath: 'projects/$projectId/files/teste.pdf',
          contentType: 'application/pdf',
          sizeBytes: 1024,
          uploadedBy: registeredUser.uid,
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: 'post-teste',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        secondFileId = await projectFileRepository.createFile(secondFile);

        expect(secondFileId, isNotEmpty);
        expect(secondFileId, isNot(firstFileId));

        // 5. Recupera o primeiro arquivo.
        final retrievedFile = await projectFileRepository.getFile(
          projectId!,
          firstFileId!,
        );

        expect(retrievedFile, isNotNull);
        expect(retrievedFile!.id, firstFileId);
        expect(retrievedFile.projectId, projectId);
        expect(retrievedFile.name, 'Documentação externa');
        expect(retrievedFile.sourceType, FileSourceType.externalLink);
        expect(
          retrievedFile.externalUrl,
          'https://example.com/documentacao',
        );
        expect(retrievedFile.uploadedBy, registeredUser.uid);
        expect(retrievedFile.createdAt, isNotNull);
        expect(retrievedFile.updatedAt, isNotNull);

        // 6. Lista os arquivos do projeto.
        final files = await projectFileRepository.getFilesForProject(
          projectId,
        );

        expect(files, hasLength(2));
        expect(
          files.map((file) => file.id),
          containsAll([firstFileId, secondFileId]),
        );

        expect(
          files.every((file) => file.projectId == projectId),
          isTrue,
        );

        // 7. Consulta arquivos vinculados a uma publicação.
        final relatedFiles =
        await projectFileRepository.getFilesForRelatedEntity(
          projectId: projectId,
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: 'post-teste',
        );

        expect(relatedFiles, hasLength(2));

        expect(
          relatedFiles.every(
                (file) =>
            file.relatedEntityType == FileRelatedEntityType.post &&
                file.relatedEntityId == 'post-teste',
          ),
          isTrue,
        );

        // 8. Atualiza os metadados do segundo arquivo.
        final updatedFile = ProjectFile(
          id: secondFileId!,
          projectId: projectId,
          name: 'Documento de teste atualizado.pdf',
          description: 'Descrição atualizada.',
          sourceType: FileSourceType.uploaded,
          storagePath: secondFile.storagePath,
          contentType: secondFile.contentType,
          sizeBytes: secondFile.sizeBytes,
          uploadedBy: registeredUser.uid,
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: 'post-teste',
          createdAt: secondFile.createdAt,
          updatedAt: DateTime.now(),
        );

        await projectFileRepository.updateFile(updatedFile);

        // 9. Confirma a atualização.
        final retrievedUpdatedFile =
        await projectFileRepository.getFile(
          projectId,
          secondFileId,
        );

        expect(retrievedUpdatedFile, isNotNull);
        expect(
          retrievedUpdatedFile!.name,
          'Documento de teste atualizado.pdf',
        );
        expect(
          retrievedUpdatedFile.description,
          'Descrição atualizada.',
        );
        expect(
          retrievedUpdatedFile.storagePath,
          secondFile.storagePath,
        );
        expect(retrievedUpdatedFile.uploadedBy, registeredUser.uid);
        expect(retrievedUpdatedFile.createdAt, isNotNull);
        expect(retrievedUpdatedFile.updatedAt, isNotNull);

        // 10. Exclui o primeiro arquivo.
        await projectFileRepository.deleteFile(
          projectId,
          firstFileId,
        );

        final deletedFile = await projectFileRepository.getFile(
          projectId,
          firstFileId,
        );

        expect(deletedFile, isNull);

        // 11. Confirma que o segundo arquivo continua existindo.
        final remainingFiles =
        await projectFileRepository.getFilesForProject(projectId);

        expect(remainingFiles, hasLength(1));
        expect(remainingFiles.single.id, secondFileId);

        // 12. Exclui o segundo arquivo.
        await projectFileRepository.deleteFile(
          projectId,
          secondFileId,
        );

        final filesAfterDeletion =
        await projectFileRepository.getFilesForProject(projectId);

        expect(filesAfterDeletion, isEmpty);
      } finally {
        // 13. Limpa os arquivos criados durante o teste.
        if (projectId != null) {
          if (firstFileId != null) {
            await projectFileRepository.deleteFile(
              projectId,
              firstFileId,
            );
          }

          if (secondFileId != null) {
            await projectFileRepository.deleteFile(
              projectId,
              secondFileId,
            );
          }

          await projectRepository.deleteProject(projectId);
        }

        await authDataSource.deleteCurrentUser();
      }
    },
  );
}