
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/post.dart';
import 'package:agile_academical_app/domain/repositories/post_repository.dart';
import 'package:agile_academical_app/domain/usecases/posts/create_post.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository postRepository;
  late CreatePost createPost;

  setUpAll(() {
    registerFallbackValue(
      Post(
        id: '',
        projectId: '',
        authorId: '',
        content: '',
        createdAt: DateTime(2000),
        updatedAt: DateTime(2000),
      ),
    );
  });

  setUp(() {
    postRepository = MockPostRepository();
    createPost = CreatePost(
      postRepository: postRepository,
    );
  });

  group('CreatePost', () {
    test('should prepare the post and return its ID', () async {
      final now = DateTime.now();

      final post = Post(
        id: 'post-1',
        projectId: 'project-1',
        authorId: 'user-1',
        content: '  Minha publicação  ',
        attachmentUrls: const ['https://example.com/file.pdf'],
        youtubeUrl: 'https://www.youtube.com/watch?v=example',
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 2)),
      );

      when(
            () => postRepository.createPost(any()),
      ).thenAnswer((invocation) async {
        final receivedPost =
        invocation.positionalArguments.first as Post;

        expect(receivedPost.id, 'post-1');
        expect(receivedPost.projectId, 'project-1');
        expect(receivedPost.authorId, 'user-1');
        expect(receivedPost.content, 'Minha publicação');
        expect(
          receivedPost.attachmentUrls,
          ['https://example.com/file.pdf'],
        );
        expect(
          receivedPost.youtubeUrl,
          'https://www.youtube.com/watch?v=example',
        );
        expect(receivedPost.createdAt, post.createdAt);
        expect(
          receivedPost.updatedAt.isAfter(post.updatedAt),
          isTrue,
        );

        return 'post-1';
      });

      final result = await createPost(post);

      expect(result, 'post-1');

      verify(
            () => postRepository.createPost(any()),
      ).called(1);
    });
  });
}
