
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agile_academical_app/domain/entities/post.dart';
import 'package:agile_academical_app/domain/repositories/post_repository.dart';
import 'package:agile_academical_app/domain/usecases/posts/get_posts_for_project.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository repository;
  late GetPostsForProject getPostsForProject;

  setUp(() {
    repository = MockPostRepository();
    getPostsForProject = GetPostsForProject(repository);
  });

  group('GetPostsForProject', () {
    const projectId = 'project-1';

    test('should return posts belonging to the project', () async {
      final posts = [
        Post(
          id: 'post-1',
          projectId: projectId,
          authorId: 'user-1',
          content: 'Primeira publicação',
          createdAt: DateTime(2026, 10, 17, 9),
          updatedAt: DateTime(2026, 10, 17, 9),
        ),
        Post(
          id: 'post-2',
          projectId: projectId,
          authorId: 'user-2',
          content: 'Segunda publicação',
          createdAt: DateTime(2026, 10, 17, 10),
          updatedAt: DateTime(2026, 10, 17, 10),
        ),
      ];

      when(
            () => repository.getPostsForProject(projectId),
      ).thenAnswer((_) async => posts);

      final result = await getPostsForProject(projectId);

      expect(result, hasLength(2));
      expect(result[0].id, 'post-1');
      expect(result[1].id, 'post-2');
      expect(
        result.every((post) => post.projectId == projectId),
        isTrue,
      );

      verify(
            () => repository.getPostsForProject(projectId),
      ).called(1);
    });

    test('should return an empty list when no posts exist', () async {
      when(
            () => repository.getPostsForProject(projectId),
      ).thenAnswer((_) async => <Post>[]);

      final result = await getPostsForProject(projectId);

      expect(result, isEmpty);

      verify(
            () => repository.getPostsForProject(projectId),
      ).called(1);
    });
  });
}
