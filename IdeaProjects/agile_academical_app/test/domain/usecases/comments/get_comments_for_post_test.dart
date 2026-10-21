import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/comment.dart';
import 'package:agile_academical_app/domain/repositories/comment_repository.dart';
import 'package:agile_academical_app/domain/usecases/comments/get_comments_for_post.dart';

class MockCommentRepository extends Mock
    implements CommentRepository {}

void main() {
  late MockCommentRepository repository;
  late GetCommentsForPost getCommentsForPost;

  setUp(() {
    repository = MockCommentRepository();
    getCommentsForPost = GetCommentsForPost(repository);
  });

  final comments = [
    Comment(
      id: 'comment-1',
      projectId: 'project-1',
      postId: 'post-1',
      authorId: 'user-1',
      content: 'Primeiro comentário',
      createdAt: DateTime(2026, 1, 10),
      updatedAt: DateTime(2026, 1, 10),
    ),
    Comment(
      id: 'comment-2',
      projectId: 'project-1',
      postId: 'post-1',
      authorId: 'user-2',
      content: 'Segundo comentário',
      createdAt: DateTime(2026, 1, 11),
      updatedAt: DateTime(2026, 1, 11),
    ),
  ];

  group('GetCommentsForPost', () {
    test('retorna os comentários da publicação solicitada', () async {
      when(
            () => repository.getCommentsForPost(
          'project-1',
          'post-1',
        ),
      ).thenAnswer((_) async => comments);

      final result = await getCommentsForPost(
        projectId: 'project-1',
        postId: 'post-1',
      );

      expect(result, hasLength(2));
      expect(result[0].id, 'comment-1');
      expect(result[1].id, 'comment-2');

      verify(
            () => repository.getCommentsForPost(
          'project-1',
          'post-1',
        ),
      ).called(1);
    });

    test('retorna uma lista vazia quando não há comentários', () async {
      when(
            () => repository.getCommentsForPost(
          'project-1',
          'post-1',
        ),
      ).thenAnswer((_) async => <Comment>[]);

      final result = await getCommentsForPost(
        projectId: 'project-1',
        postId: 'post-1',
      );

      expect(result, isEmpty);
    });
  });
}