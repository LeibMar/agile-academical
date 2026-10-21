import '../../entities/comment.dart';

class CommentRules {
  static Comment prepareForCreation(Comment comment) {
    final now = DateTime.now();

    return Comment(
      id: comment.id,
      projectId: comment.projectId,
      postId: comment.postId,
      authorId: comment.authorId,
      content: comment.content.trim(),
      createdAt: comment.createdAt,
      updatedAt: now,
    );
  }

  static Comment prepareForUpdate({
    required Comment current,
    required Comment updated,
  }) {
    return Comment(
      id: current.id,
      projectId: current.projectId,
      postId: current.postId,
      authorId: current.authorId,
      content: updated.content.trim(),
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}