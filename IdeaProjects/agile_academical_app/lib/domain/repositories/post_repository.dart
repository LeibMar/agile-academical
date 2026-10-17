
import '../entities/post.dart';

abstract class PostRepository {
  Future<String> createPost(Post post);

  Future<Post?> getPost(String projectId, String postId);

  Future<List<Post>> getPostsForProject(String projectId);

  Future<void> updatePost(Post post);

  Future<void> deletePost(String projectId, String postId);
}
