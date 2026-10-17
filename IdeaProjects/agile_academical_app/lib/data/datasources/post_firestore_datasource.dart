
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post_model.dart';

class PostFirestoreDataSource {
  final FirebaseFirestore firestore;

  PostFirestoreDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _postsCollection(
      String projectId,
      ) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('posts');
  }

  /// Cria uma publicação e retorna o ID gerado pelo Firestore.
  Future<String> createPost(PostModel post) async {
    final docRef = _postsCollection(post.projectId).doc();

    final data = post.toFirestore()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);

    return docRef.id;
  }

  /// Busca uma publicação pelo projeto e pelo ID do documento.
  /// Retorna null caso o documento não exista.
  Future<PostModel?> getPost(
      String projectId,
      String postId,
      ) async {
    final doc = await _postsCollection(projectId).doc(postId).get();

    if (!doc.exists) {
      return null;
    }

    return PostModel.fromFirestore(doc);
  }

  /// Lista as publicações de um projeto, da mais recente para a mais antiga.
  Future<List<PostModel>> getPostsForProject(
      String projectId,
      ) async {
    final snapshot = await _postsCollection(projectId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PostModel.fromFirestore(doc))
        .toList();
  }

  /// Atualiza uma publicação sem alterar sua data de criação.
  Future<void> updatePost(PostModel post) async {
    final data = post.toFirestore();

    data.remove('createdAt');
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _postsCollection(post.projectId)
        .doc(post.id)
        .update(data);
  }

  /// Exclui uma publicação do projeto.
  Future<void> deletePost(
      String projectId,
      String postId,
      ) async {
    await _postsCollection(projectId).doc(postId).delete();
  }
}
