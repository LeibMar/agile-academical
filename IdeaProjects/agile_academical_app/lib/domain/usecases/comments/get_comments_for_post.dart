import '../../entities/comment.dart';
import '../../repositories/comment_repository.dart';

class GetCommentsForPost {
  final CommentRepository repository;

  GetCommentsForPost(this.repository);

  Future<List<Comment>> call({
    required String projectId,
    required String postId,
  }) {
    return repository.getCommentsForPost(
      projectId,
      postId,
    );
  }
}