
class Comment {
  final String id;
  final String projectId;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    required this.projectId,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}
