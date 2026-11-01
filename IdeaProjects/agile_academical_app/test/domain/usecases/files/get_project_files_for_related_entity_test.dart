import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/project_file.dart';
import 'package:agile_academical_app/domain/repositories/project_file_repository.dart';
import 'package:agile_academical_app/domain/usecases/files/get_project_files_for_related_entity.dart';

class MockProjectFileRepository extends Mock
    implements ProjectFileRepository {}

//class FakeFileRelatedEntityType extends Fake
   // implements FileRelatedEntityType {}

void main() {
  late MockProjectFileRepository projectFileRepository;
  late GetProjectFilesForRelatedEntity getProjectFilesForRelatedEntity;

  //setUpAll(() {
    //registerFallbackValue(FakeFileRelatedEntityType());
  //});

  setUp(() {
    projectFileRepository = MockProjectFileRepository();

    getProjectFilesForRelatedEntity = GetProjectFilesForRelatedEntity(
      projectFileRepository: projectFileRepository,
    );
  });

  group('GetProjectFilesForRelatedEntity', () {
    final now = DateTime(2026, 10, 31, 12);

    final files = [
      ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'anexo-publicacao.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/anexo-publicacao.pdf',
        contentType: 'application/pdf',
        sizeBytes: 2048,
        uploadedBy: 'user-1',
        relatedEntityType: FileRelatedEntityType.post,
        relatedEntityId: 'post-1',
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
        relatedEntityType: FileRelatedEntityType.post,
        relatedEntityId: 'post-1',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    test('should return files associated with the specified entity',
            () async {
          when(
                () => projectFileRepository.getFilesForRelatedEntity(
              projectId: 'project-1',
              relatedEntityType: FileRelatedEntityType.post,
              relatedEntityId: 'post-1',
            ),
          ).thenAnswer((_) async => files);

          final result = await getProjectFilesForRelatedEntity(
            projectId: 'project-1',
            relatedEntityType: FileRelatedEntityType.post,
            relatedEntityId: 'post-1',
          );

          expect(result, hasLength(2));
          expect(result[0].relatedEntityType, FileRelatedEntityType.post);
          expect(result[0].relatedEntityId, 'post-1');
          expect(result[1].relatedEntityType, FileRelatedEntityType.post);
          expect(result[1].relatedEntityId, 'post-1');

          verify(
                () => projectFileRepository.getFilesForRelatedEntity(
              projectId: 'project-1',
              relatedEntityType: FileRelatedEntityType.post,
              relatedEntityId: 'post-1',
            ),
          ).called(1);
        });

    test('should return an empty list when no files are associated',
            () async {
          when(
                () => projectFileRepository.getFilesForRelatedEntity(
              projectId: 'project-1',
              relatedEntityType: FileRelatedEntityType.task,
              relatedEntityId: 'task-1',
            ),
          ).thenAnswer((_) async => []);

          final result = await getProjectFilesForRelatedEntity(
            projectId: 'project-1',
            relatedEntityType: FileRelatedEntityType.task,
            relatedEntityId: 'task-1',
          );

          expect(result, isEmpty);
        });

    test('should reject an empty project ID', () async {
      expect(
            () => getProjectFilesForRelatedEntity(
          projectId: '  ',
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: 'post-1',
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.getFilesForRelatedEntity(
          projectId: '',
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: 'post-1',
        ),
      );
    });

    test('should reject an empty related entity ID', () async {
      expect(
            () => getProjectFilesForRelatedEntity(
          projectId: 'project-1',
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: '  ',
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.getFilesForRelatedEntity(
          projectId: 'project-1',
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: '',
        ),
      );
    });
  });
}