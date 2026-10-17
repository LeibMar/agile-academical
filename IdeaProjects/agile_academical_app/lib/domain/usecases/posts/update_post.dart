
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';
import 'post_rules.dart';

class UpdatePost {
  final PostRepository repository;

  UpdatePost(this.repository);

  Future<void> call(Post post) async {
    final current = await repository.getPost(
      post.projectId,
      post.id,
    );

    if (current == null) {
      throw StateError(
        'A publicação não foi encontrada para atualização.',
      );
    }

    final postToUpdate = PostRules.prepareForUpdate(
      current,
      post,
    );

    await repository.updatePost(postToUpdate);
  }
}
