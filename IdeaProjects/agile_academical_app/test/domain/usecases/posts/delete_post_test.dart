
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/repositories/post_repository.dart';
import 'package:agile_academical_app/domain/usecases/posts/delete_post.dart';

class FakePostRepository implements PostRepository {
  String? deletedProjectId;
  String? deletedPostId;
  int deleteCallCount = 0;

  @override
  Future<void> deletePost(String projectId, String postId) async {
    deletedProjectId = projectId;
    deletedPostId = postId;
    deleteCallCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late FakePostRepository repository;
  late DeletePost deletePost;

  setUp(() {
    repository = FakePostRepository();
    deletePost = DeletePost(repository);
  });

  group('DeletePost', () {
    test('deve encaminhar os identificadores ao repositório', () async {
      await deletePost('project-001', 'post-001');

      expect(repository.deletedProjectId, 'project-001');
      expect(repository.deletedPostId, 'post-001');
      expect(repository.deleteCallCount, 1);
    });
  });
}
