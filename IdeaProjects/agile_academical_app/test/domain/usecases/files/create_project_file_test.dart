import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/project_file.dart';
import 'package:agile_academical_app/domain/repositories/project_file_repository.dart';
import 'package:agile_academical_app/domain/usecases/files/create_project_file.dart';

class MockProjectFileRepository extends Mock
    implements ProjectFileRepository {}

void main() {
  late MockProjectFileRepository projectFileRepository;
  late CreateProjectFile createProjectFile;

  setUpAll(() {
    registerFallbackValue(
      ProjectFile(
        id: '',
        projectId: '',
        name: '',
        sourceType: FileSourceType.uploaded,
        storagePath: '',
        uploadedBy: '',
        createdAt: DateTime(2000),
        updatedAt: DateTime(2000),
      ),
    );
  });

  setUp(() {
    projectFileRepository = MockProjectFileRepository();

    createProjectFile = CreateProjectFile(
      projectFileRepository: projectFileRepository,
    );
  });

  group('CreateProjectFile', () {
    test('should prepare an uploaded file and return its ID', () async {
      final now = DateTime(2026, 10, 31, 12);

      final file = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: '  documento.pdf  ',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/documento.pdf',
        contentType: 'application/pdf',
        sizeBytes: 2048,
        uploadedBy: 'user-1',
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 2)),
      );

      when(
            () => projectFileRepository.createFile(any()),
      ).thenAnswer((invocation) async {
        final receivedFile =
        invocation.positionalArguments.first as ProjectFile;

        expect(receivedFile.id, 'file-1');
        expect(receivedFile.projectId, 'project-1');
        expect(receivedFile.name, 'documento.pdf');
        expect(receivedFile.sourceType, FileSourceType.uploaded);
        expect(
          receivedFile.storagePath,
          'projects/project-1/files/documento.pdf',
        );
        expect(receivedFile.contentType, 'application/pdf');
        expect(receivedFile.sizeBytes, 2048);
        expect(receivedFile.uploadedBy, 'user-1');
        expect(receivedFile.createdAt, now);
        expect(receivedFile.updatedAt, now);

        return 'file-1';
      });

      final result = await createProjectFile(
        file,
        now: now,
      );

      expect(result, 'file-1');

      verify(
            () => projectFileRepository.createFile(any()),
      ).called(1);
    });

    test('should prepare an external link and return its ID', () async {
      final now = DateTime(2026, 10, 31, 12);

      final file = ProjectFile(
        id: 'file-2',
        projectId: 'project-1',
        name: '  Documentação  ',
        sourceType: FileSourceType.externalLink,
        externalUrl: '  https://example.com/documentacao  ',
        uploadedBy: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      when(
            () => projectFileRepository.createFile(any()),
      ).thenAnswer((invocation) async {
        final receivedFile =
        invocation.positionalArguments.first as ProjectFile;

        expect(receivedFile.id, 'file-2');
        expect(receivedFile.projectId, 'project-1');
        expect(receivedFile.name, 'Documentação');
        expect(
          receivedFile.sourceType,
          FileSourceType.externalLink,
        );
        expect(
          receivedFile.externalUrl,
          'https://example.com/documentacao',
        );
        expect(receivedFile.uploadedBy, 'user-1');
        expect(receivedFile.createdAt, now);
        expect(receivedFile.updatedAt, now);

        return 'file-2';
      });

      final result = await createProjectFile(
        file,
        now: now,
      );

      expect(result, 'file-2');

      verify(
            () => projectFileRepository.createFile(any()),
      ).called(1);
    });

    test('should reject invalid data without calling repository', () async {
      final now = DateTime(2026, 10, 31, 12);

      final file = ProjectFile(
        id: 'file-3',
        projectId: 'project-1',
        name: '   ',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/documento.pdf',
        uploadedBy: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      expect(
            () => createProjectFile(file, now: now),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.createFile(any()),
      );
    });
  });
}