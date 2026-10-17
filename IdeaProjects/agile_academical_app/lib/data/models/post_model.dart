
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.projectId,
    required super.authorId,
    required super.content,
    super.attachmentUrls,
    super.youtubeUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Converte a entidade Post para o modelo concreto.
  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      projectId: post.projectId,
      authorId: post.authorId,
      content: post.content,
      attachmentUrls: post.attachmentUrls,
      youtubeUrl: post.youtubeUrl,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
    );
  }

  /// Constrói o modelo a partir de um documento do Firestore.
  factory PostModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    if (data == null) {
      throw StateError(
        'Não foi possível ler a publicação: '
            'documento ${doc.id} sem dados.',
      );
    }

    return PostModel(
      id: doc.id,
      projectId: data['projectId'] as String,
      authorId: data['authorId'] as String,
      content: data['content'] as String,
      attachmentUrls: List<String>.from(
        data['attachmentUrls'] ?? const <String>[],
      ),
      youtubeUrl: data['youtubeUrl'] as String?,
      createdAt: _requiredDateTimeFromFirestore(data['createdAt']),
      updatedAt: _requiredDateTimeFromFirestore(data['updatedAt']),
    );
  }

  /// Converte o modelo para um mapa que pode ser salvo no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'authorId': authorId,
      'content': content,
      'attachmentUrls': attachmentUrls,
      'youtubeUrl': youtubeUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime? _dateTimeFromFirestore(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    throw FormatException(
      'Tipo de data não suportado no Firestore: '
          '${value.runtimeType}',
    );
  }

  static DateTime _requiredDateTimeFromFirestore(dynamic value) {
    final date = _dateTimeFromFirestore(value);

    if (date == null) {
      throw const FormatException(
        'Uma data obrigatória da publicação não foi encontrada.',
      );
    }

    return date;
  }
}
