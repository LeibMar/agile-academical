
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

class GetPostsForProject {
  final PostRepository repository;

  GetPostsForProject(this.repository);

  Future<List<Post>> call(String projectId) {
    return repository.getPostsForProject(projectId);
  }
}
