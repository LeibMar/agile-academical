
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/repositories/project_file_repository.dart';
import 'package:agile_academical_app/domain/usecases/files/delete_project_file.dart';

class MockProjectFileRepository extends Mock
    implements ProjectFileRepository {}

void main() {
  late MockProjectFileRepository projectFileRepository;
  late DeleteProjectFile deleteProjectFile;

  setUp(() {
    projectFileRepository = MockProjectFileRepository();

    deleteProjectFile = DeleteProjectFile(
      projectFileRepository: projectFileRepository,
    );
  });

  group('DeleteProjectFile', () {
    test('should delete the requested file', () async {
      when(
            () => projectFileRepository.deleteFile('project-1', 'file-1'),
      ).thenAnswer((_) async {});

      await deleteProjectFile(
        projectId: 'project-1',
        fileId: 'file-1',
      );

      verify(
            () => projectFileRepository.deleteFile('project-1', 'file-1'),
      ).called(1);
    });

    test('should reject an empty project ID', () async {
      await expectLater(
        deleteProjectFile(
          projectId: '  ',
          fileId: 'file-1',
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.deleteFile('  ', 'file-1'),
      );
    });

    test('should reject an empty file ID', () async {
      await expectLater(
        deleteProjectFile(
          projectId: 'project-1',
          fileId: '  ',
        ),
        throwsArgumentError,
      );

      verifyNever(
            () => projectFileRepository.deleteFile('project-1', '  '),
      );
    });
  });
}
