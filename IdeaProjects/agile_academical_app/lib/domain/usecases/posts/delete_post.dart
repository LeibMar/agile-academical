
import '../../repositories/post_repository.dart';

class DeletePost {
  final PostRepository repository;

  DeletePost(this.repository);

  Future<void> call(String projectId, String postId) {
    return repository.deletePost(projectId, postId);
  }
}
