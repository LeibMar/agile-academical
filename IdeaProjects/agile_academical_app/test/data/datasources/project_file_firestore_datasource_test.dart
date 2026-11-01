
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../lib/data/datasources/project_file_firestore_datasource.dart';
import '../../../lib/data/models/project_file_model.dart';
import '../../../lib/domain/entities/project_file.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore firestore;
  late MockCollectionReference projectsCollection;
  late MockDocumentReference projectDocument;
  late MockCollectionReference filesCollection;
  late MockDocumentReference fileDocument;
  late MockQuery query;
  late ProjectFileFirestoreDataSource dataSource;

  const projectId = 'project-123';
  const fileId = 'file-123';

  final now = DateTime(2026, 10, 31, 12);

  ProjectFileModel createFile({
    String id = fileId,
    String name = 'documento.pdf',
  }) {
    return ProjectFileModel(
      id: id,
      projectId: projectId,
      name: name,
      sourceType: FileSourceType.uploaded,
      storagePath: 'projects/$projectId/files/$id',
      contentType: 'application/pdf',
      sizeBytes: 1024,
      uploadedBy: 'user-123',
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> createFirestoreData() {
    return {
      'projectId': projectId,
      'name': 'documento.pdf',
      'description': null,
      'sourceType': 'uploaded',
      'storagePath': 'projects/$projectId/files/$fileId',
      'contentType': 'application/pdf',
      'sizeBytes': 1024,
      'externalUrl': null,
      'uploadedBy': 'user-123',
      'relatedEntityType': null,
      'relatedEntityId': null,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };
  }

  setUp(() {
    firestore = MockFirebaseFirestore();
    projectsCollection = MockCollectionReference();
    projectDocument = MockDocumentReference();
    filesCollection = MockCollectionReference();
    fileDocument = MockDocumentReference();
    query = MockQuery();

    when(() => firestore.collection('projects'))
        .thenReturn(projectsCollection);

    when(() => projectsCollection.doc(projectId))
        .thenReturn(projectDocument);

    when(() => projectDocument.collection('files'))
        .thenReturn(filesCollection);

    when(() => filesCollection.doc()).thenReturn(fileDocument);

    dataSource = ProjectFileFirestoreDataSource(
      firestore: firestore,
    );
  });

  group('ProjectFileFirestoreDataSource', () {
    test('deve criar os metadados e retornar o ID gerado', () async {
      final file = createFile();

      when(() => fileDocument.id).thenReturn(fileId);

      when(() => fileDocument.set(any()))
          .thenAnswer((_) async {});

      final result = await dataSource.createFile(file);

      expect(result, fileId);

      verify(() => fileDocument.set(any())).called(1);
    });

    test('deve recuperar um arquivo existente', () async {
      final document = MockDocumentSnapshot();

      when(() => filesCollection.doc(fileId))
          .thenReturn(fileDocument);

      when(() => fileDocument.get())
          .thenAnswer((_) async => document);

      when(() => document.exists).thenReturn(true);
      when(() => document.data()).thenReturn(createFirestoreData());
      when(() => document.id).thenReturn(fileId);

      final result = await dataSource.getFile(projectId, fileId);

      expect(result, isNotNull);
      expect(result!.id, fileId);
      expect(result.projectId, projectId);
      expect(result.name, 'documento.pdf');
      expect(result.sourceType, FileSourceType.uploaded);
    });

    test('deve retornar null quando o arquivo não existir', () async {
      final document = MockDocumentSnapshot();

      when(() => filesCollection.doc(fileId))
          .thenReturn(fileDocument);

      when(() => fileDocument.get())
          .thenAnswer((_) async => document);

      when(() => document.exists).thenReturn(false);

      final result = await dataSource.getFile(projectId, fileId);

      expect(result, isNull);
    });

    test('deve listar os arquivos de um projeto', () async {
      final snapshot = MockQuerySnapshot();
      final document = MockQueryDocumentSnapshot();

      when(() => filesCollection.orderBy(
        'createdAt',
        descending: true,
      )).thenReturn(query);

      when(() => query.get()).thenAnswer((_) async => snapshot);

      when(() => snapshot.docs).thenReturn([document]);

      when(() => document.data()).thenReturn(createFirestoreData());
      when(() => document.id).thenReturn(fileId);

      final result = await dataSource.getFilesForProject(projectId);

      expect(result, hasLength(1));
      expect(result.first.id, fileId);
      expect(result.first.name, 'documento.pdf');
    });

    test('deve listar arquivos associados a uma entidade', () async {
      final snapshot = MockQuerySnapshot();
      final document = MockQueryDocumentSnapshot();

      when(() => filesCollection.where(
        'relatedEntityType',
        isEqualTo: 'post',
      )).thenReturn(query);

      when(() => query.where(
        'relatedEntityId',
        isEqualTo: 'post-123',
      )).thenReturn(query);

      when(() => query.orderBy(
        'createdAt',
        descending: true,
      )).thenReturn(query);

      when(() => query.get()).thenAnswer((_) async => snapshot);

      final relatedData = createFirestoreData()
        ..['relatedEntityType'] = 'post'
        ..['relatedEntityId'] = 'post-123';

      when(() => snapshot.docs).thenReturn([document]);

      when(() => document.data()).thenReturn(relatedData);
      when(() => document.id).thenReturn(fileId);

      final result = await dataSource.getFilesForRelatedEntity(
        projectId: projectId,
        relatedEntityType: FileRelatedEntityType.post,
        relatedEntityId: 'post-123',
      );

      expect(result, hasLength(1));
      expect(result.first.relatedEntityType, FileRelatedEntityType.post);
      expect(result.first.relatedEntityId, 'post-123');
    });

    test('deve atualizar os metadados de um arquivo', () async {
      final file = createFile(
        name: 'documento-atualizado.pdf',
      );

      when(() => filesCollection.doc(fileId))
          .thenReturn(fileDocument);

      when(() => fileDocument.update(any()))
          .thenAnswer((_) async {});

      await dataSource.updateFile(file);

      verify(() => fileDocument.update(any())).called(1);
    });

    test('deve excluir os metadados de um arquivo', () async {
      when(() => filesCollection.doc(fileId))
          .thenReturn(fileDocument);

      when(() => fileDocument.delete())
          .thenAnswer((_) async {});

      await dataSource.deleteFile(projectId, fileId);

      verify(() => fileDocument.delete()).called(1);
    });
  });
}
