import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/project_file.dart';
import 'package:agile_academical_app/domain/repositories/project_file_repository.dart';
import 'package:agile_academical_app/domain/usecases/files/get_project_files.dart';

class MockProjectFileRepository extends Mock
    implements ProjectFileRepository {}

void main() {
  late MockProjectFileRepository projectFileRepository;
  late GetProjectFiles getProjectFiles;

  setUp(() {
    projectFileRepository = MockProjectFileRepository();

    getProjectFiles = GetProjectFiles(
      projectFileRepository: projectFileRepository,
    );
  });

  group('GetProjectFiles', () {
    final now = DateTime(2026, 10, 31, 12);

    final files = [
      ProjectFile(
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
      ),
      ProjectFile(
        id: 'file-2',
        projectId: 'project-1',
        name: 'referencia',
        sourceType: FileSourceType.externalLink,
        externalUrl: 'https://example.com/referencia',
        uploadedBy: 'user-2',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    test('should return all files belonging to the project', () async {
      when(
            () => projectFileRepository.getFilesForProject('project-1'),
      ).thenAnswer((_) async => files);

      final result = await getProjectFiles('project-1');

      expect(result, hasLength(2));
      expect(result[0].id, 'file-1');
      expect(result[1].id, 'file-2');

      verify(
            () => projectFileRepository.getFilesForProject('project-1'),
      ).called(1);
    });

    test('should return an empty list when the project has no files',
            () async {
          when(
                () => projectFileRepository.getFilesForProject('project-1'),
          ).thenAnswer((_) async => []);

          final result = await getProjectFiles('project-1');

          expect(result, isEmpty);

          verify(
                () => projectFileRepository.getFilesForProject('project-1'),
          ).called(1);
        });

    test('should reject an empty project ID', () async {
      expect(
            () => getProjectFiles('  '),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.getFilesForProject(any()),
      );
    });
  });
}