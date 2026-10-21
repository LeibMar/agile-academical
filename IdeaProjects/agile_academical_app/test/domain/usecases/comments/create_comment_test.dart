import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/comment.dart';
import 'package:agile_academical_app/domain/repositories/comment_repository.dart';
import 'package:agile_academical_app/domain/usecases/comments/create_comment.dart';

class MockCommentRepository extends Mock
    implements CommentRepository {}

class FakeComment extends Fake implements Comment {}

void main() {
  late MockCommentRepository repository;
  late CreateComment createComment;

  setUpAll(() {
    registerFallbackValue(FakeComment());
  });

  setUp(() {
    repository = MockCommentRepository();
    createComment = CreateComment(repository);
  });

  Comment createTestComment({
    String content = 'Comentário de teste',
  }) {
    return Comment(
      id: 'comment-1',
      projectId: 'project-1',
      postId: 'post-1',
      authorId: 'user-1',
      content: content,
      createdAt: DateTime(2026, 1, 10),
      updatedAt: DateTime(2026, 1, 10),
    );
  }

  group('CreateComment', () {
    test('prepara o comentário e retorna o ID gerado', () async {
      final comment = createTestComment(
        content: '  Meu comentário  ',
      );

      when(
            () => repository.createComment(any()),
      ).thenAnswer((_) async => 'generated-comment-id');

      final result = await createComment(comment);

      expect(result, 'generated-comment-id');

      final captured = verify(
            () => repository.createComment(captureAny()),
      ).captured.single as Comment;

      expect(captured.content, 'Meu comentário');
      expect(captured.projectId, comment.projectId);
      expect(captured.postId, comment.postId);
      expect(captured.authorId, comment.authorId);
      expect(captured.createdAt, comment.createdAt);
      expect(
        captured.updatedAt.isAfter(comment.updatedAt),
        isTrue,
      );
    });

    test('propaga erros retornados pelo repositório', () async {
      final comment = createTestComment();

      when(
            () => repository.createComment(any()),
      ).thenThrow(Exception('Erro ao criar comentário'));

      expect(
            () => createComment(comment),
        throwsA(isA<Exception>()),
      );
    });
  });
}