
import '../../entities/post.dart';

class PostRules {
  static Post prepareForCreation(Post post) {
    return Post(
      id: post.id,
      projectId: post.projectId,
      authorId: post.authorId,
      content: post.content.trim(),
      attachmentUrls: List<String>.unmodifiable(
        post.attachmentUrls,
      ),
      youtubeUrl: post.youtubeUrl,
      createdAt: post.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static Post prepareForUpdate(Post current, Post updated) {
    return Post(
      id: current.id,
      projectId: current.projectId,
      authorId: current.authorId,
      content: updated.content.trim(),
      attachmentUrls: List<String>.unmodifiable(
        updated.attachmentUrls,
      ),
      youtubeUrl: updated.youtubeUrl,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
