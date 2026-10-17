
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/post.dart';
import 'package:agile_academical_app/domain/repositories/post_repository.dart';
import 'package:agile_academical_app/domain/usecases/posts/update_post.dart';

class FakePostRepository implements PostRepository {
  Post? currentPost;
  Post? updatedPost;

  @override
  Future<Post?> getPost(String projectId, String postId) async {
    if (currentPost?.projectId == projectId &&
        currentPost?.id == postId) {
      return currentPost;
    }

    return null;
  }

  @override
  Future<void> updatePost(Post post) async {
    updatedPost = post;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late FakePostRepository repository;
  late UpdatePost updatePost;

  setUp(() {
    repository = FakePostRepository();
    updatePost = UpdatePost(repository);
  });

  group('UpdatePost', () {
    test(
      'deve atualizar a publicação preservando autor e data de criação',
          () async {
        final createdAt = DateTime(2026, 10, 10, 9);
        final originalPost = Post(
          id: 'post-001',
          projectId: 'project-001',
          authorId: 'user-001',
          content: 'Conteúdo original',
          createdAt: createdAt,
          updatedAt: DateTime(2026, 10, 10, 9),
        );

        repository.currentPost = originalPost;

        final postToUpdate = Post(
          id: 'post-001',
          projectId: 'project-001',
          authorId: 'user-999',
          content: '  Conteúdo atualizado  ',
          attachmentUrls: const [
            'https://example.com/documento.pdf',
          ],
          youtubeUrl: 'https://www.youtube.com/watch?v=example',
          createdAt: DateTime(2026, 10, 15),
          updatedAt: DateTime(2026, 10, 15),
        );

        await updatePost(postToUpdate);

        final result = repository.updatedPost;

        expect(result, isNotNull);
        expect(result!.id, originalPost.id);
        expect(result.projectId, originalPost.projectId);
        expect(result.authorId, originalPost.authorId);
        expect(result.createdAt, createdAt);
        expect(result.content, 'Conteúdo atualizado');
        expect(
          result.attachmentUrls,
          ['https://example.com/documento.pdf'],
        );
        expect(
          result.youtubeUrl,
          'https://www.youtube.com/watch?v=example',
        );
        expect(
          result.updatedAt.isAfter(originalPost.updatedAt),
          isTrue,
        );
      },
    );

    test(
      'deve lançar StateError quando a publicação não existir',
          () async {
        final post = Post(
          id: 'post-inexistente',
          projectId: 'project-001',
          authorId: 'user-001',
          content: 'Publicação inexistente',
          createdAt: DateTime(2026, 10, 10),
          updatedAt: DateTime(2026, 10, 10),
        );

        await expectLater(
              () => updatePost(post),
          throwsA(isA<StateError>()),
        );

        expect(repository.updatedPost, isNull);
      },
    );
  });
}
