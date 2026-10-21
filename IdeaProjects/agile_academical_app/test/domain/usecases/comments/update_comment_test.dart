import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/comment.dart';
import 'package:agile_academical_app/domain/repositories/comment_repository.dart';
import 'package:agile_academical_app/domain/usecases/comments/update_comment.dart';

class MockCommentRepository extends Mock
    implements CommentRepository {}

class FakeComment extends Fake implements Comment {}

void main() {
  late MockCommentRepository repository;
  late UpdateComment updateComment;

  setUpAll(() {
    registerFallbackValue(FakeComment());
  });

  setUp(() {
    repository = MockCommentRepository();
    updateComment = UpdateComment(repository);
  });

  final currentComment = Comment(
    id: 'comment-1',
    projectId: 'project-1',
    postId: 'post-1',
    authorId: 'user-1',
    content: 'Conteúdo original',
    createdAt: DateTime(2026, 1, 10),
    updatedAt: DateTime(2026, 1, 10),
  );

  group('UpdateComment', () {
    test('atualiza o conteúdo do comentário existente', () async {
      final updatedComment = Comment(
        id: 'comment-1',
        projectId: 'project-1',
        postId: 'post-1',
        authorId: 'user-1',
        content: '  Conteúdo atualizado  ',
        createdAt: DateTime(2026, 1, 10),
        updatedAt: DateTime(2026, 1, 11),
      );

      when(
            () => repository.getComment(
          'project-1',
          'post-1',
          'comment-1',
        ),
      ).thenAnswer((_) async => currentComment);

      when(
            () => repository.updateComment(any()),
      ).thenAnswer((_) async {});

      await updateComment(updatedComment);

      final captured = verify(
            () => repository.updateComment(captureAny()),
      ).captured.single as Comment;

      expect(captured.content, 'Conteúdo atualizado');
      expect(captured.id, currentComment.id);
      expect(captured.projectId, currentComment.projectId);
      expect(captured.postId, currentComment.postId);
      expect(captured.authorId, currentComment.authorId);
      expect(captured.createdAt, currentComment.createdAt);

      verify(
            () => repository.getComment(
          'project-1',
          'post-1',
          'comment-1',
        ),
      ).called(1);
    });

    test('lança StateError quando o comentário não existe', () async {
      final comment = Comment(
        id: 'comment-inexistente',
        projectId: 'project-1',
        postId: 'post-1',
        authorId: 'user-1',
        content: 'Conteúdo atualizado',
        createdAt: DateTime(2026, 1, 10),
        updatedAt: DateTime(2026, 1, 11),
      );

      when(
            () => repository.getComment(
          'project-1',
          'post-1',
          'comment-inexistente',
        ),
      ).thenAnswer((_) async => null);

      expect(
            () => updateComment(comment),
        throwsA(isA<StateError>()),
      );

      verifyNever(
            () => repository.updateComment(any()),
      );
    });
  });
}