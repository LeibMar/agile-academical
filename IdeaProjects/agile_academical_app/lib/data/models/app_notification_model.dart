
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.recipientId,
    required super.projectId,
    required super.type,
    required super.actorId,
    required super.entityType,
    required super.entityId,
    required super.message,
    required super.createdAt,
    super.readAt,
  });

  /// Converte a entidade AppNotification para o modelo concreto.
  factory AppNotificationModel.fromEntity(
      AppNotification notification,
      ) {
    return AppNotificationModel(
      id: notification.id,
      recipientId: notification.recipientId,
      projectId: notification.projectId,
      type: notification.type,
      actorId: notification.actorId,
      entityType: notification.entityType,
      entityId: notification.entityId,
      message: notification.message,
      createdAt: notification.createdAt,
      readAt: notification.readAt,
    );
  }

  /// Constrói o modelo a partir de um documento do Firestore.
  factory AppNotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    if (data == null) {
      throw StateError(
        'Não foi possível ler a notificação: '
            'documento ${doc.id} sem dados.',
      );
    }

    return AppNotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] as String,
      projectId: data['projectId'] as String,
      type: NotificationType.values.byName(
        data['type'] as String,
      ),
      actorId: data['actorId'] as String,
      entityType: NotificationEntityType.values.byName(
        data['entityType'] as String,
      ),
      entityId: data['entityId'] as String,
      message: data['message'] as String,
      createdAt: _requiredDateTimeFromFirestore(data['createdAt']),
      readAt: _dateTimeFromFirestore(data['readAt']),
    );
  }

  /// Converte o modelo para um mapa que pode ser salvo no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'projectId': projectId,
      'type': type.name,
      'actorId': actorId,
      'entityType': entityType.name,
      'entityId': entityId,
      'message': message,
      'createdAt': createdAt,
      'readAt': readAt,
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
        'A data de criação da notificação não foi encontrada.',
      );
    }

    return date;
  }
}
