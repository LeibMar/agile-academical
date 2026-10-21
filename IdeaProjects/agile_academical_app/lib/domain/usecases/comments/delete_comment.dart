import '../../entities/comment.dart';
import '../../repositories/comment_repository.dart';

class DeleteComment {
  final CommentRepository repository;

  DeleteComment(this.repository);

  Future<void> call({
    required String projectId,
    required String postId,
    required String commentId,
  }) {
    return repository.deleteComment(
      projectId,
      postId,
      commentId,
    );
  }
}