import '../../entities/comment.dart';
import '../../repositories/comment_repository.dart';

class GetComment {
  final CommentRepository repository;

  GetComment(this.repository);

  Future<Comment?> call({
    required String projectId,
    required String postId,
    required String commentId,
  }) {
    return repository.getComment(
      projectId,
      postId,
      commentId,
    );
  }
}