import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/repositories/comment_repository.dart';
import 'package:agile_academical_app/domain/usecases/comments/delete_comment.dart';

class MockCommentRepository extends Mock
    implements CommentRepository {}

void main() {
  late MockCommentRepository repository;
  late DeleteComment deleteComment;

  setUp(() {
    repository = MockCommentRepository();
    deleteComment = DeleteComment(repository);
  });

  group('DeleteComment', () {
    test('solicita a exclusão do comentário correto', () async {
      when(
            () => repository.deleteComment(
          'project-1',
          'post-1',
          'comment-1',
        ),
      ).thenAnswer((_) async {});

      await deleteComment(
        projectId: 'project-1',
        postId: 'post-1',
        commentId: 'comment-1',
      );

      verify(
            () => repository.deleteComment(
          'project-1',
          'post-1',
          'comment-1',
        ),
      ).called(1);
    });

    test('propaga erros retornados pelo repositório', () async {
      when(
            () => repository.deleteComment(
          'project-1',
          'post-1',
          'comment-1',
        ),
      ).thenThrow(Exception('Erro ao excluir comentário'));

      expect(
            () => deleteComment(
          projectId: 'project-1',
          postId: 'post-1',
          commentId: 'comment-1',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}