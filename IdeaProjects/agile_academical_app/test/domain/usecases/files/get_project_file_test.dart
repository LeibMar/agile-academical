import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/project_file.dart';
import 'package:agile_academical_app/domain/repositories/project_file_repository.dart';
import 'package:agile_academical_app/domain/usecases/files/get_project_file.dart';

class MockProjectFileRepository extends Mock
    implements ProjectFileRepository {}

void main() {
  late MockProjectFileRepository projectFileRepository;
  late GetProjectFile getProjectFile;

  setUp(() {
    projectFileRepository = MockProjectFileRepository();

    getProjectFile = GetProjectFile(
      projectFileRepository: projectFileRepository,
    );
  });

  group('GetProjectFile', () {
    final now = DateTime(2026, 10, 31, 12);

    final file = ProjectFile(
      id: 'file-1',
      projectId: 'project-1',
      name: 'documento.pdf',
      sourceType: FileSourceType.uploaded,
      storagePath: 'projects/project-1/files/documento.pdf',
      contentType: 'application/pdf',
      sizeBytes: 1024,
      uploadedBy: 'user-1',
      createdAt: now,
      updatedAt: now,
    );

    test('should return the requested file', () async {
      when(
            () => projectFileRepository.getFile('project-1', 'file-1'),
      ).thenAnswer((_) async => file);

      final result = await getProjectFile(
        projectId: 'project-1',
        fileId: 'file-1',
      );

      expect(result, isNotNull);
      expect(result!.id, 'file-1');
      expect(result.projectId, 'project-1');
      expect(result.name, 'documento.pdf');

      verify(
            () => projectFileRepository.getFile('project-1', 'file-1'),
      ).called(1);
    });

    test('should return null when the file does not exist', () async {
      when(
            () => projectFileRepository.getFile('project-1', 'file-404'),
      ).thenAnswer((_) async => null);

      final result = await getProjectFile(
        projectId: 'project-1',
        fileId: 'file-404',
      );

      expect(result, isNull);

      verify(
            () => projectFileRepository.getFile('project-1', 'file-404'),
      ).called(1);
    });

    test('should reject an empty project ID', () async {
      expect(
            () => getProjectFile(
          projectId: '  ',
          fileId: 'file-1',
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.getFile(any(), any()),
      );
    });

    test('should reject an empty file ID', () async {
      expect(
            () => getProjectFile(
          projectId: 'project-1',
          fileId: '  ',
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.getFile(any(), any()),
      );
    });
  });
}