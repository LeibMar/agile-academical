import '../../entities/comment.dart';
import '../../repositories/comment_repository.dart';
import 'comment_rules.dart';

class UpdateComment {
  final CommentRepository repository;

  UpdateComment(this.repository);

  Future<void> call(Comment comment) async {
    final currentComment = await repository.getComment(
      comment.projectId,
      comment.postId,
      comment.id,
    );

    if (currentComment == null) {
      throw StateError(
        'O comentário não foi encontrado para atualização.',
      );
    }

    final preparedComment = CommentRules.prepareForUpdate(
      current: currentComment,
      updated: comment,
    );

    await repository.updateComment(preparedComment);
  }
}