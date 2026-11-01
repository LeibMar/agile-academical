
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project_file_model.dart';
import '../../domain/entities/project_file.dart';

class ProjectFileFirestoreDataSource {
  final FirebaseFirestore firestore;

  ProjectFileFirestoreDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _filesCollection(
      String projectId,
      ) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('files');
  }

  /// Cria os metadados de um arquivo e retorna o ID gerado pelo Firestore.
  Future<String> createFile(ProjectFileModel file) async {
    final docRef = _filesCollection(file.projectId).doc();

    final data = file.toFirestore()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);

    return docRef.id;
  }

  /// Busca um arquivo pelo projeto e pelo ID do documento.
  /// Retorna null caso o documento não exista.
  Future<ProjectFileModel?> getFile(
      String projectId,
      String fileId,
      ) async {
    final doc = await _filesCollection(projectId).doc(fileId).get();

    if (!doc.exists) {
      return null;
    }

    return ProjectFileModel.fromFirestore(doc);
  }

  /// Lista os arquivos de um projeto, do mais recente para o mais antigo.
  Future<List<ProjectFileModel>> getFilesForProject(
      String projectId,
      ) async {
    final snapshot = await _filesCollection(projectId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProjectFileModel.fromFirestore(doc))
        .toList();
  }

  /// Lista arquivos associados a uma publicação, tarefa ou etapa.
  Future<List<ProjectFileModel>> getFilesForRelatedEntity({
    required String projectId,
    required FileRelatedEntityType relatedEntityType,
    required String relatedEntityId,
  }) async {
    final snapshot = await _filesCollection(projectId)
        .where('relatedEntityType', isEqualTo: relatedEntityType.name)
        .where('relatedEntityId', isEqualTo: relatedEntityId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProjectFileModel.fromFirestore(doc))
        .toList();
  }

  /// Atualiza os metadados sem alterar a data de criação.
  Future<void> updateFile(ProjectFileModel file) async {
    final data = file.toFirestore();

    data.remove('createdAt');
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _filesCollection(file.projectId)
        .doc(file.id)
        .update(data);
  }

  /// Exclui os metadados do arquivo no Firestore.
  ///
  /// Não exclui o conteúdo binário do Firebase Storage.
  Future<void> deleteFile(
      String projectId,
      String fileId,
      ) async {
    await _filesCollection(projectId).doc(fileId).delete();
  }
}
