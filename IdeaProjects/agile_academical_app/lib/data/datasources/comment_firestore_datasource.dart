import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';

class CommentFirestoreDataSource {
  final FirebaseFirestore firestore;

  CommentFirestoreDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _commentsCollection(
      String projectId,
      String postId,
      ) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('posts')
        .doc(postId)
        .collection('comments');
  }

  Future<String> createComment(CommentModel comment) async {
    final docRef = _commentsCollection(
      comment.projectId,
      comment.postId,
    ).doc();

    await docRef.set({
      ...comment.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<CommentModel?> getComment(
      String projectId,
      String postId,
      String commentId,
      ) async {
    final doc = await _commentsCollection(
      projectId,
      postId,
    ).doc(commentId).get();

    if (!doc.exists) return null;

    return CommentModel.fromFirestore(doc);
  }

  Future<List<CommentModel>> getCommentsForPost(
      String projectId,
      String postId,
      ) async {
    final snapshot = await _commentsCollection(
      projectId,
      postId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map(CommentModel.fromFirestore)
        .toList();
  }

  Future<void> updateComment(CommentModel comment) async {
    await _commentsCollection(
      comment.projectId,
      comment.postId,
    ).doc(comment.id).update({
      'content': comment.content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(
      String projectId,
      String postId,
      String commentId,
      ) async {
    await _commentsCollection(
      projectId,
      postId,
    ).doc(commentId).delete();
  }
}