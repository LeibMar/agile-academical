
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/data/models/project_file_model.dart';
import 'package:agile_academical_app/domain/entities/project_file.dart';

class MockDocumentSnapshot
    extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('ProjectFileModel', () {
    final createdAt = DateTime(2026, 10, 20, 10, 30);
    final updatedAt = DateTime(2026, 10, 21, 14, 45);

    test('fromEntity converte corretamente a entidade', () {
      final file = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'Regulamento.pdf',
        description: 'Regulamento do projeto',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/file-1.pdf',
        contentType: 'application/pdf',
        sizeBytes: 2048,
        uploadedBy: 'user-1',
        relatedEntityType: FileRelatedEntityType.post,
        relatedEntityId: 'post-1',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final model = ProjectFileModel.fromEntity(file);

      expect(model.id, file.id);
      expect(model.projectId, file.projectId);
      expect(model.name, file.name);
      expect(model.description, file.description);
      expect(model.sourceType, file.sourceType);
      expect(model.storagePath, file.storagePath);
      expect(model.contentType, file.contentType);
      expect(model.sizeBytes, file.sizeBytes);
      expect(model.externalUrl, file.externalUrl);
      expect(model.uploadedBy, file.uploadedBy);
      expect(model.relatedEntityType, file.relatedEntityType);
      expect(model.relatedEntityId, file.relatedEntityId);
      expect(model.createdAt, file.createdAt);
      expect(model.updatedAt, file.updatedAt);
    });

    test('toFirestore gera os campos esperados', () {
      final file = ProjectFile(
        id: 'file-1',
        projectId: 'project-1',
        name: 'Regulamento.pdf',
        sourceType: FileSourceType.uploaded,
        storagePath: 'projects/project-1/files/file-1.pdf',
        contentType: 'application/pdf',
        sizeBytes: 2048,
        uploadedBy: 'user-1',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final model = ProjectFileModel.fromEntity(file);
      final data = model.toFirestore();

      expect(data['projectId'], file.projectId);
      expect(data['name'], file.name);
      expect(data['sourceType'], 'uploaded');
      expect(data['storagePath'], file.storagePath);
      expect(data['contentType'], file.contentType);
      expect(data['sizeBytes'], file.sizeBytes);
      expect(data['uploadedBy'], file.uploadedBy);
      expect(data['createdAt'], createdAt);
      expect(data['updatedAt'], updatedAt);

      expect(data.containsKey('id'), isFalse);
    });

    test('fromFirestore reconstrói corretamente um arquivo enviado', () {
      final doc = MockDocumentSnapshot();

      when(() => doc.id).thenReturn('file-1');
      when(() => doc.data()).thenReturn({
        'projectId': 'project-1',
        'name': 'Regulamento.pdf',
        'description': 'Regulamento do projeto',
        'sourceType': 'uploaded',
        'storagePath': 'projects/project-1/files/file-1.pdf',
        'contentType': 'application/pdf',
        'sizeBytes': 2048,
        'externalUrl': null,
        'uploadedBy': 'user-1',
        'relatedEntityType': 'task',
        'relatedEntityId': 'task-1',
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      final model = ProjectFileModel.fromFirestore(doc);

      expect(model.id, 'file-1');
      expect(model.projectId, 'project-1');
      expect(model.name, 'Regulamento.pdf');
      expect(model.sourceType, FileSourceType.uploaded);
      expect(
        model.storagePath,
        'projects/project-1/files/file-1.pdf',
      );
      expect(model.contentType, 'application/pdf');
      expect(model.sizeBytes, 2048);
      expect(model.externalUrl, isNull);
      expect(model.uploadedBy, 'user-1');
      expect(model.relatedEntityType, FileRelatedEntityType.task);
      expect(model.relatedEntityId, 'task-1');
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
    });

    test('fromFirestore reconstrói corretamente um link externo', () {
      final doc = MockDocumentSnapshot();

      when(() => doc.id).thenReturn('file-2');
      when(() => doc.data()).thenReturn({
        'projectId': 'project-1',
        'name': 'Documentação externa',
        'description': 'Documentação hospedada externamente',
        'sourceType': 'externalLink',
        'storagePath': null,
        'contentType': null,
        'sizeBytes': null,
        'externalUrl': 'https://example.com/documentacao',
        'uploadedBy': 'user-2',
        'relatedEntityType': 'stage',
        'relatedEntityId': 'stage-1',
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      final model = ProjectFileModel.fromFirestore(doc);

      expect(model.id, 'file-2');
      expect(model.sourceType, FileSourceType.externalLink);
      expect(model.storagePath, isNull);
      expect(model.contentType, isNull);
      expect(model.sizeBytes, isNull);
      expect(
        model.externalUrl,
        'https://example.com/documentacao',
      );
      expect(model.uploadedBy, 'user-2');
      expect(model.relatedEntityType, FileRelatedEntityType.stage);
      expect(model.relatedEntityId, 'stage-1');
    });

    test('fromFirestore aceita arquivo sem associação', () {
      final doc = MockDocumentSnapshot();

      when(() => doc.id).thenReturn('file-3');
      when(() => doc.data()).thenReturn({
        'projectId': 'project-1',
        'name': 'Material.pdf',
        'sourceType': 'uploaded',
        'storagePath': 'projects/project-1/files/file-3.pdf',
        'contentType': 'application/pdf',
        'sizeBytes': 1024,
        'externalUrl': null,
        'uploadedBy': 'user-1',
        'relatedEntityType': null,
        'relatedEntityId': null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      final model = ProjectFileModel.fromFirestore(doc);

      expect(model.relatedEntityType, isNull);
      expect(model.relatedEntityId, isNull);
    });
  });
}
