
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';
import 'post_rules.dart';

class CreatePost {
  final PostRepository postRepository;

  CreatePost({
    required this.postRepository,
  });

  Future<String> call(Post post) async {
    final postToCreate = PostRules.prepareForCreation(post);

    return postRepository.createPost(postToCreate);
  }
}
