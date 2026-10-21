import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/comment.dart';
import 'package:agile_academical_app/domain/repositories/comment_repository.dart';
import 'package:agile_academical_app/domain/usecases/comments/get_comment.dart';

class MockCommentRepository extends Mock
    implements CommentRepository {}

void main() {
  late MockCommentRepository repository;
  late GetComment getComment;

  setUp(() {
    repository = MockCommentRepository();
    getComment = GetComment(repository);
  });

  final comment = Comment(
    id: 'comment-1',
    projectId: 'project-1',
    postId: 'post-1',
    authorId: 'user-1',
    content: 'Comentário de teste',
    createdAt: DateTime(2026, 1, 10),
    updatedAt: DateTime(2026, 1, 10),
  );

  group('GetComment', () {
    test('retorna o comentário encontrado', () async {
      when(
            () => repository.getComment(
          'project-1',
          'post-1',
          'comment-1',
        ),
      ).thenAnswer((_) async => comment);

      final result = await getComment(
        projectId: 'project-1',
        postId: 'post-1',
        commentId: 'comment-1',
      );

      expect(result, isNotNull);
      expect(result!.id, 'comment-1');
      expect(result.projectId, 'project-1');
      expect(result.postId, 'post-1');
      expect(result.content, 'Comentário de teste');

      verify(
            () => repository.getComment(
          'project-1',
          'post-1',
          'comment-1',
        ),
      ).called(1);
    });

    test('retorna null quando o comentário não existe', () async {
      when(
            () => repository.getComment(
          'project-1',
          'post-1',
          'comment-inexistente',
        ),
      ).thenAnswer((_) async => null);

      final result = await getComment(
        projectId: 'project-1',
        postId: 'post-1',
        commentId: 'comment-inexistente',
      );

      expect(result, isNull);
    });
  });
}