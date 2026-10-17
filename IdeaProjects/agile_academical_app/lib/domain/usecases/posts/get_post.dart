
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

class GetPost {
  final PostRepository repository;

  GetPost(this.repository);

  Future<Post?> call(String projectId, String postId) {
    return repository.getPost(projectId, postId);
  }
}
