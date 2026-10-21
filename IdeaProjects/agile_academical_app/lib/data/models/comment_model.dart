
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.projectId,
    required super.postId,
    required super.authorId,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Converte a entidade Comment para o modelo concreto.
  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      projectId: comment.projectId,
      postId: comment.postId,
      authorId: comment.authorId,
      content: comment.content,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
    );
  }

  /// Constrói o modelo a partir de um documento do Firestore.
  factory CommentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    if (data == null) {
      throw StateError(
        'Não foi possível ler o comentário: '
            'documento ${doc.id} sem dados.',
      );
    }

    return CommentModel(
      id: doc.id,
      projectId: data['projectId'] as String,
      postId: data['postId'] as String,
      authorId: data['authorId'] as String,
      content: data['content'] as String,
      createdAt: _requiredDateTimeFromFirestore(data['createdAt']),
      updatedAt: _requiredDateTimeFromFirestore(data['updatedAt']),
    );
  }

  /// Converte o modelo para um mapa que pode ser salvo no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'postId': postId,
      'authorId': authorId,
      'content': content,
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
        'Uma data obrigatória do comentário não foi encontrada.',
      );
    }

    return date;
  }
}
