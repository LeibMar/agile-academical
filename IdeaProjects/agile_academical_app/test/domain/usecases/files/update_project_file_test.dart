
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/project_file.dart';
import 'package:agile_academical_app/domain/repositories/project_file_repository.dart';
import 'package:agile_academical_app/domain/usecases/files/update_project_file.dart';

class MockProjectFileRepository extends Mock
    implements ProjectFileRepository {}

void main() {
  late MockProjectFileRepository projectFileRepository;
  late UpdateProjectFile updateProjectFile;

  setUpAll(() {
    registerFallbackValue(
      ProjectFile(
        id: 'fallback-file',
        projectId: 'fallback-project',
        name: 'fallback.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: 'fallback/path',
        uploadedBy: 'fallback-user',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    projectFileRepository = MockProjectFileRepository();

    updateProjectFile = UpdateProjectFile(
      projectFileRepository: projectFileRepository,
    );
  });

  group('UpdateProjectFile', () {
    final createdAt = DateTime(2026, 10, 20, 10);
    final now = DateTime(2026, 10, 31, 12);

    final currentFile = ProjectFile(
      id: 'file-1',
      projectId: 'project-1',
      name: 'documento-original.pdf',
      description: 'Descrição original',
      sourceType: FileSourceType.uploaded,
      storagePath: 'projects/project-1/files/documento.pdf',
      contentType: 'application/pdf',
      sizeBytes: 1024,
      uploadedBy: 'user-1',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final updatedFile = ProjectFile(
      id: 'file-1',
      projectId: 'project-1',
      name: 'documento-atualizado.pdf',
      description: 'Descrição atualizada',
      sourceType: FileSourceType.uploaded,
      storagePath: 'projects/project-1/files/documento.pdf',
      contentType: 'application/pdf',
      sizeBytes: 2048,
      uploadedBy: 'user-1',
      relatedEntityType: FileRelatedEntityType.post,
      relatedEntityId: 'post-1',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    test('should update an existing file', () async {
      when(
            () => projectFileRepository.getFile('project-1', 'file-1'),
      ).thenAnswer((_) async => currentFile);

      when(
            () => projectFileRepository.updateFile(any()),
      ).thenAnswer((_) async {});

      await updateProjectFile(
        updatedFile,
        now: now,
      );

      final capturedFile = verify(
            () => projectFileRepository.updateFile(captureAny()),
      ).captured.single as ProjectFile;

      expect(capturedFile.id, currentFile.id);
      expect(capturedFile.projectId, currentFile.projectId);
      expect(capturedFile.uploadedBy, currentFile.uploadedBy);
      expect(capturedFile.storagePath, currentFile.storagePath);
      expect(capturedFile.createdAt, createdAt);

      expect(capturedFile.name, 'documento-atualizado.pdf');
      expect(capturedFile.description, 'Descrição atualizada');
      expect(capturedFile.sizeBytes, currentFile.sizeBytes);
      expect(capturedFile.contentType, currentFile.contentType);
      expect(capturedFile.relatedEntityType, FileRelatedEntityType.post);
      expect(capturedFile.relatedEntityId, 'post-1');
      expect(capturedFile.updatedAt, now);

      verify(
            () => projectFileRepository.getFile('project-1', 'file-1'),
      ).called(1);
    });

    test('should reject an empty file ID', () async {
      final invalidFile = ProjectFile(
        id: '  ',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/documento.pdf',
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      await expectLater(
        updateProjectFile(invalidFile),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.getFile('project-1', '  '),
      );

      verifyNever(
            () => projectFileRepository.updateFile(any()),
      );
    });

    test('should reject an empty project ID', () async {
      final invalidFile = ProjectFile(
        id: 'file-1',
        projectId: '  ',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/documento.pdf',
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      await expectLater(
        updateProjectFile(invalidFile),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.getFile('  ', 'file-1'),
      );

      verifyNever(
            () => projectFileRepository.updateFile(any()),
      );
    });

    test('should reject updating a file that does not exist', () async {
      when(
            () => projectFileRepository.getFile('project-1', 'file-404'),
      ).thenAnswer((_) async => null);

      final nonexistentFile = ProjectFile(
        id: 'file-404',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/documento.pdf',
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      await expectLater(
        updateProjectFile(nonexistentFile),
        throwsA(isA<StateError>()),
      );

      verify(
            () => projectFileRepository.getFile('project-1', 'file-404'),
      ).called(1);

      verifyNever(
            () => projectFileRepository.updateFile(any()),
      );
    });

    test('should reject changing immutable fields', () async {
      when(
            () => projectFileRepository.getFile('project-1', 'file-1'),
      ).thenAnswer((_) async => currentFile);

      final invalidFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: currentFile.storagePath,
        uploadedBy: 'user-2',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      await expectLater(
        updateProjectFile(invalidFile),
        throwsArgumentError,
      );

      verify(
            () => projectFileRepository.getFile('project-1', 'file-1'),
      ).called(1);

      verifyNever(
            () => projectFileRepository.updateFile(any()),
      );
    });
  });
}
