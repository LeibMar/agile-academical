
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_firestore_datasource.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final PostFirestoreDataSource dataSource;

  PostRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<String> createPost(Post post) async {
    final model = PostModel.fromEntity(post);
    return dataSource.createPost(model);
  }

  @override
  Future<Post?> getPost(String projectId, String postId) async {
    final model = await dataSource.getPost(projectId, postId);
    return model;
  }

  @override
  Future<List<Post>> getPostsForProject(String projectId) async {
    final models = await dataSource.getPostsForProject(projectId);
    return models;
  }

  @override
  Future<void> updatePost(Post post) async {
    final model = PostModel.fromEntity(post);
    await dataSource.updatePost(model);
  }

  @override
  Future<void> deletePost(String projectId, String postId) async {
    await dataSource.deletePost(projectId, postId);
  }
}
