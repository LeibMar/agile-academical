import '../entities/comment.dart';

abstract class CommentRepository {
  Future<String> createComment(Comment comment);

  Future<Comment?> getComment(
      String projectId,
      String postId,
      String commentId,
      );

  Future<List<Comment>> getCommentsForPost(
      String projectId,
      String postId,
      );

  Future<void> updateComment(Comment comment);

  Future<void> deleteComment(
      String projectId,
      String postId,
      String commentId,
      );
}