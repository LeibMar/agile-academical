
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/post.dart';
import 'package:agile_academical_app/domain/repositories/post_repository.dart';
import 'package:agile_academical_app/domain/usecases/posts/get_post.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository repository;
  late GetPost getPost;

  setUp(() {
    repository = MockPostRepository();
    getPost = GetPost(repository);
  });

  group('GetPost', () {
    const projectId = 'project-1';
    const postId = 'post-1';

    test('should return the post when it exists', () async {
      final post = Post(
        id: postId,
        projectId: projectId,
        authorId: 'user-1',
        content: 'Minha publicação',
        createdAt: DateTime(2026, 10, 17, 10),
        updatedAt: DateTime(2026, 10, 17, 10),
      );

      when(
            () => repository.getPost(projectId, postId),
      ).thenAnswer((_) async => post);

      final result = await getPost(projectId, postId);

      expect(result, isNotNull);
      expect(result!.id, postId);
      expect(result.projectId, projectId);
      expect(result.content, 'Minha publicação');

      verify(
            () => repository.getPost(projectId, postId),
      ).called(1);
    });

    test('should return null when the post does not exist', () async {
      when(
            () => repository.getPost(projectId, postId),
      ).thenAnswer((_) async => null);

      final result = await getPost(projectId, postId);

      expect(result, isNull);

      verify(
            () => repository.getPost(projectId, postId),
      ).called(1);
    });
  });
}
