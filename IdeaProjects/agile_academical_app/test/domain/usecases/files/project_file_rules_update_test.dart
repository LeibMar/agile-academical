
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/project_file.dart';
import 'package:agile_academical_app/domain/usecases/files/project_file_rules.dart';

void main() {
  group('ProjectFileRules.prepareForUpdate', () {
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

    test('should update metadata and preserve immutable fields', () {
      final updatedFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: ' documento-atualizado.pdf ',
        description: ' Descrição atualizada ',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/documento.pdf',
        contentType: 'application/msword',
        sizeBytes: 2048,
        uploadedBy: 'user-1',
        relatedEntityType: FileRelatedEntityType.post,
        relatedEntityId: 'post-1',
        createdAt: DateTime(2026, 10, 25),
        updatedAt: DateTime(2026, 10, 25),
      );

      final result = ProjectFileRules.prepareForUpdate(
        currentFile,
        updatedFile,
        now: now,
      );

      expect(result.id, currentFile.id);
      expect(result.projectId, currentFile.projectId);
      expect(result.uploadedBy, currentFile.uploadedBy);
      expect(result.sourceType, currentFile.sourceType);
      expect(result.storagePath, currentFile.storagePath);
      expect(result.externalUrl, currentFile.externalUrl);
      expect(result.createdAt, createdAt);

      expect(result.name, 'documento-atualizado.pdf');
      expect(result.description, 'Descrição atualizada');
      expect(result.sizeBytes, 1024);
      expect(result.contentType, 'application/pdf');
      expect(result.relatedEntityType, FileRelatedEntityType.post);
      expect(result.relatedEntityId, 'post-1');
      expect(result.updatedAt, now);
    });

    test('should preserve current optional metadata when update values are null',
            () {
          final updatedFile = ProjectFile(
            id: 'file-1',
            projectId: 'project-1',
            name: 'documento-atualizado.pdf',
            sourceType: FileSourceType.uploaded,
            storagePath: currentFile.storagePath,
            uploadedBy: 'user-1',
            createdAt: createdAt,
            updatedAt: createdAt,
          );

          final result = ProjectFileRules.prepareForUpdate(
            currentFile,
            updatedFile,
            now: now,
          );

          expect(result.contentType, currentFile.contentType);
          expect(result.sizeBytes, currentFile.sizeBytes);
          expect(result.description, isNull);
          expect(result.updatedAt, now);
        });

    test('should reject changing the file ID', () {
      final updatedFile = ProjectFile(
        id: 'file-2',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: currentFile.storagePath,
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
            () => ProjectFileRules.prepareForUpdate(
          currentFile,
          updatedFile,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('should reject changing the project ID', () {
      final updatedFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-2',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: currentFile.storagePath,
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
            () => ProjectFileRules.prepareForUpdate(
          currentFile,
          updatedFile,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('should reject changing the uploader', () {
      final updatedFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: currentFile.storagePath,
        uploadedBy: 'user-2',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
            () => ProjectFileRules.prepareForUpdate(
          currentFile,
          updatedFile,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('should reject changing the source type', () {
      final updatedFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.externalLink,
        externalUrl: 'https://example.com/documento',
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
            () => ProjectFileRules.prepareForUpdate(
          currentFile,
          updatedFile,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('should reject changing the storage path', () {
      final updatedFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/outro-documento.pdf',
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
            () => ProjectFileRules.prepareForUpdate(
          currentFile,
          updatedFile,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('should reject an empty updated name', () {
      final updatedFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: '  ',
        sourceType: FileSourceType.uploaded,
        storagePath: currentFile.storagePath,
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
            () => ProjectFileRules.prepareForUpdate(
          currentFile,
          updatedFile,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('should reject an invalid related entity association', () {
      final updatedFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: currentFile.storagePath,
        uploadedBy: 'user-1',
        relatedEntityType: FileRelatedEntityType.post,
        relatedEntityId: '  ',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
            () => ProjectFileRules.prepareForUpdate(
          currentFile,
          updatedFile,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('should preserve current file size when update provides a negative size', () {
      final updatedFile = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'documento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: currentFile.storagePath,
        sizeBytes: -1,
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final result = ProjectFileRules.prepareForUpdate(
        currentFile,
        updatedFile,
        now: now,
      );

      expect(result.sizeBytes, currentFile.sizeBytes);
      expect(result.contentType, currentFile.contentType);
    });
  });
}
