import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_firestore_datasource.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentFirestoreDataSource dataSource;

  CommentRepositoryImpl({required this.dataSource});

  @override
  Future<String> createComment(Comment comment) {
    return dataSource.createComment(
      CommentModel.fromEntity(comment),
    );
  }

  @override
  Future<Comment?> getComment(
      String projectId,
      String postId,
      String commentId,
      ) {
    return dataSource.getComment(
      projectId,
      postId,
      commentId,
    );
  }

  @override
  Future<List<Comment>> getCommentsForPost(
      String projectId,
      String postId,
      ) async {
    return dataSource.getCommentsForPost(
      projectId,
      postId,
    );
  }

  @override
  Future<void> updateComment(Comment comment) {
    return dataSource.updateComment(
      CommentModel.fromEntity(comment),
    );
  }

  @override
  Future<void> deleteComment(
      String projectId,
      String postId,
      String commentId,
      ) {
    return dataSource.deleteComment(
      projectId,
      postId,
      commentId,
    );
  }
}