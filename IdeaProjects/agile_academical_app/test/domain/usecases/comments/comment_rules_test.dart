import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/comment.dart';
import 'package:agile_academical_app/domain/usecases/comments/comment_rules.dart';

void main() {
  group('CommentRules', () {
    final createdAt = DateTime(2026, 1, 10, 10, 0);
    final updatedAt = DateTime(2026, 1, 11, 10, 0);

    Comment createTestComment({
      String id = 'comment-1',
      String projectId = 'project-1',
      String postId = 'post-1',
      String authorId = 'user-1',
      String content = 'Comentário de teste',
      DateTime? commentCreatedAt,
      DateTime? commentUpdatedAt,
    }) {
      return Comment(
        id: id,
        projectId: projectId,
        postId: postId,
        authorId: authorId,
        content: content,
        createdAt: commentCreatedAt ?? createdAt,
        updatedAt: commentUpdatedAt ?? updatedAt,
      );
    }

    group('prepareForCreation', () {
      test('remove espaços excedentes do conteúdo', () {
        final comment = createTestComment(
          content: '  Meu comentário  ',
        );

        final result = CommentRules.prepareForCreation(comment);

        expect(result.content, 'Meu comentário');
      });

      test('preserva os identificadores e a data de criação', () {
        final comment = createTestComment();

        final result = CommentRules.prepareForCreation(comment);

        expect(result.id, comment.id);
        expect(result.projectId, comment.projectId);
        expect(result.postId, comment.postId);
        expect(result.authorId, comment.authorId);
        expect(result.createdAt, comment.createdAt);
      });

      test('define uma nova data de atualização', () {
        final comment = createTestComment(
          commentUpdatedAt: DateTime(2020, 1, 1),
        );

        final before = DateTime.now();
        final result = CommentRules.prepareForCreation(comment);
        final after = DateTime.now();

        expect(
          result.updatedAt.isBefore(before),
          isFalse,
        );
        expect(
          result.updatedAt.isAfter(after),
          isFalse,
        );
      });
    });

    group('prepareForUpdate', () {
      test('remove espaços excedentes do conteúdo atualizado', () {
        final current = createTestComment();
        final updated = createTestComment(
          content: '  Comentário editado  ',
        );

        final result = CommentRules.prepareForUpdate(
          current: current,
          updated: updated,
        );

        expect(result.content, 'Comentário editado');
      });

      test('preserva os dados originais do comentário', () {
        final current = createTestComment(
          id: 'comment-original',
          projectId: 'project-original',
          postId: 'post-original',
          authorId: 'author-original',
        );

        final updated = createTestComment(
          id: 'comment-alterado',
          projectId: 'project-alterado',
          postId: 'post-alterado',
          authorId: 'author-alterado',
          content: 'Novo conteúdo',
        );

        final result = CommentRules.prepareForUpdate(
          current: current,
          updated: updated,
        );

        expect(result.id, current.id);
        expect(result.projectId, current.projectId);
        expect(result.postId, current.postId);
        expect(result.authorId, current.authorId);
        expect(result.createdAt, current.createdAt);
      });

      test('define uma nova data de atualização', () {
        final current = createTestComment(
          commentUpdatedAt: DateTime(2020, 1, 1),
        );
        final updated = createTestComment();

        final before = DateTime.now();
        final result = CommentRules.prepareForUpdate(
          current: current,
          updated: updated,
        );
        final after = DateTime.now();

        expect(
          result.updatedAt.isBefore(before),
          isFalse,
        );
        expect(
          result.updatedAt.isAfter(after),
          isFalse,
        );
      });
    });
  });
}