import '../../entities/comment.dart';
import '../../repositories/comment_repository.dart';
import 'comment_rules.dart';

class CreateComment {
  final CommentRepository repository;

  CreateComment(this.repository);

  Future<String> call(Comment comment) async {
    final preparedComment = CommentRules.prepareForCreation(comment);

    return repository.createComment(preparedComment);
  }
}