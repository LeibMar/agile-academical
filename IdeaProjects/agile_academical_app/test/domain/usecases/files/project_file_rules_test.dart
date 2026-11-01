import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/project_file.dart';
import 'package:agile_academical_app/domain/usecases/files/project_file_rules.dart';

void main() {
  group('ProjectFileRules', () {
    final now = DateTime(2026, 10, 31, 12);

    ProjectFile createUploadedFile({
      String projectId = 'project-1',
      String name = 'documento.pdf',
      String uploadedBy = 'user-1',
      String storagePath = 'projects/project-1/files/documento.pdf',
      int? sizeBytes = 1024,
      FileRelatedEntityType? relatedEntityType,
      String? relatedEntityId,
    }) {
      return ProjectFile(
        id: 'file-1',
        projectId: projectId,
        name: name,
        sourceType: FileSourceType.uploaded,
        storagePath: storagePath,
        contentType: 'application/pdf',
        sizeBytes: sizeBytes,
        uploadedBy: uploadedBy,
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
        createdAt: now,
        updatedAt: now,
      );
    }

    ProjectFile createExternalLink({
      String projectId = 'project-1',
      String name = 'Documentação',
      String uploadedBy = 'user-1',
      String? externalUrl = 'https://example.com/documentacao',
      FileRelatedEntityType? relatedEntityType,
      String? relatedEntityId,
    }) {
      return ProjectFile(
        id: 'file-2',
        projectId: projectId,
        name: name,
        sourceType: FileSourceType.externalLink,
        externalUrl: externalUrl,
        uploadedBy: uploadedBy,
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
        createdAt: now,
        updatedAt: now,
      );
    }

    group('prepareForCreation', () {
      test('deve preparar corretamente um arquivo enviado', () {
        final file = createUploadedFile(
          name: '  documento.pdf  ',
        );

        final result = ProjectFileRules.prepareForCreation(
          file,
          now: now,
        );

        expect(result.name, 'documento.pdf');
        expect(result.projectId, 'project-1');
        expect(result.uploadedBy, 'user-1');
        expect(result.storagePath, file.storagePath);
        expect(result.sourceType, FileSourceType.uploaded);
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
      });

      test('deve preparar corretamente um link externo', () {
        final file = createExternalLink(
          name: '  Documentação  ',
          externalUrl: '  https://example.com/docs  ',
        );

        final result = ProjectFileRules.prepareForCreation(
          file,
          now: now,
        );

        expect(result.name, 'Documentação');
        expect(
          result.externalUrl,
          'https://example.com/docs',
        );
        expect(result.sourceType, FileSourceType.externalLink);
      });

      test('deve preservar a associação com uma entidade', () {
        final file = createUploadedFile(
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: 'post-1',
        );

        final result = ProjectFileRules.prepareForCreation(
          file,
          now: now,
        );

        expect(
          result.relatedEntityType,
          FileRelatedEntityType.post,
        );
        expect(result.relatedEntityId, 'post-1');
      });

      test('deve rejeitar projeto com ID vazio', () {
        final file = createUploadedFile(projectId: '  ');

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar nome vazio', () {
        final file = createUploadedFile(name: '  ');

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar responsável vazio', () {
        final file = createUploadedFile(uploadedBy: '  ');

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar caminho vazio em arquivo enviado', () {
        final file = createUploadedFile(storagePath: '  ');

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar URL externa vazia', () {
        final file = createExternalLink(externalUrl: '  ');

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar URL externa com esquema inválido', () {
        final file = createExternalLink(
          externalUrl: 'ftp://example.com/documento',
        );

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar URL externa sem esquema', () {
        final file = createExternalLink(
          externalUrl: 'example.com/documento',
        );

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar tamanho negativo', () {
        final file = createUploadedFile(sizeBytes: -1);

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar ID relacionado sem tipo', () {
        final file = createUploadedFile(
          relatedEntityId: 'post-1',
        );

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar tipo relacionado sem ID', () {
        final file = createUploadedFile(
          relatedEntityType: FileRelatedEntityType.post,
        );

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar ID relacionado vazio', () {
        final file = createUploadedFile(
          relatedEntityType: FileRelatedEntityType.post,
          relatedEntityId: '  ',
        );

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar URL externa em arquivo enviado', () {
        final file = ProjectFile(
          id: 'file-1',
          projectId: 'project-1',
          name: 'documento.pdf',
          sourceType: FileSourceType.uploaded,
          storagePath: 'projects/project-1/files/documento.pdf',
          externalUrl: 'https://example.com',
          uploadedBy: 'user-1',
          createdAt: now,
          updatedAt: now,
        );

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });

      test('deve rejeitar caminho Storage em link externo', () {
        final file = ProjectFile(
          id: 'file-2',
          projectId: 'project-1',
          name: 'Documentação',
          sourceType: FileSourceType.externalLink,
          externalUrl: 'https://example.com',
          storagePath: 'projects/project-1/files/documento.pdf',
          uploadedBy: 'user-1',
          createdAt: now,
          updatedAt: now,
        );

        expect(
              () => ProjectFileRules.prepareForCreation(file),
          throwsArgumentError,
        );
      });
    });
  });
}