import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/comment.dart';
import 'package:agile_academical_app/data/models/comment_model.dart';

void main() {
  group('CommentModel', () {
    final createdAt = DateTime(2026, 1, 10, 10, 30);
    final updatedAt = DateTime(2026, 1, 11, 14, 45);

    final comment = Comment(
      id: 'comment-1',
      projectId: 'project-1',
      postId: 'post-1',
      authorId: 'user-1',
      content: 'Comentário de teste',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    test('fromEntity converte corretamente a entidade', () {
      final model = CommentModel.fromEntity(comment);

      expect(model.id, comment.id);
      expect(model.projectId, comment.projectId);
      expect(model.postId, comment.postId);
      expect(model.authorId, comment.authorId);
      expect(model.content, comment.content);
      expect(model.createdAt, comment.createdAt);
      expect(model.updatedAt, comment.updatedAt);
    });

    test('toFirestore gera os campos esperados', () {
      final model = CommentModel.fromEntity(comment);

      final data = model.toFirestore();

      expect(data['projectId'], comment.projectId);
      expect(data['postId'], comment.postId);
      expect(data['authorId'], comment.authorId);
      expect(data['content'], comment.content);
      expect(data['createdAt'], comment.createdAt);
      expect(data['updatedAt'], comment.updatedAt);

      expect(data.containsKey('id'), isFalse);
    });
  });
}