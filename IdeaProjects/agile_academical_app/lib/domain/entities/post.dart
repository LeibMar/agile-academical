
class Post {
  final String id;
  final String projectId;
  final String authorId;
  final String content;
  final List<String> attachmentUrls;
  final String? youtubeUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.content,
    this.attachmentUrls = const [],
    this.youtubeUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
