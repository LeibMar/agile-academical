
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project_file.dart';

class ProjectFileModel extends ProjectFile {
  const ProjectFileModel({
    required super.id,
    required super.projectId,
    required super.name,
    super.description,
    required super.sourceType,
    super.storagePath,
    super.contentType,
    super.sizeBytes,
    super.externalUrl,
    required super.uploadedBy,
    super.relatedEntityType,
    super.relatedEntityId,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Converte a entidade ProjectFile para o modelo concreto.
  factory ProjectFileModel.fromEntity(ProjectFile file) {
    return ProjectFileModel(
      id: file.id,
      projectId: file.projectId,
      name: file.name,
      description: file.description,
      sourceType: file.sourceType,
      storagePath: file.storagePath,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      externalUrl: file.externalUrl,
      uploadedBy: file.uploadedBy,
      relatedEntityType: file.relatedEntityType,
      relatedEntityId: file.relatedEntityId,
      createdAt: file.createdAt,
      updatedAt: file.updatedAt,
    );
  }

  /// Constrói o modelo a partir de um documento do Firestore.
  factory ProjectFileModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    if (data == null) {
      throw StateError(
        'Não foi possível ler o arquivo: '
            'documento ${doc.id} sem dados.',
      );
    }

    return ProjectFileModel(
      id: doc.id,
      projectId: data['projectId'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      sourceType: FileSourceType.values.byName(
        data['sourceType'] as String,
      ),
      storagePath: data['storagePath'] as String?,
      contentType: data['contentType'] as String?,
      sizeBytes: data['sizeBytes'] as int?,
      externalUrl: data['externalUrl'] as String?,
      uploadedBy: data['uploadedBy'] as String,
      relatedEntityType: data['relatedEntityType'] == null
          ? null
          : FileRelatedEntityType.values.byName(
        data['relatedEntityType'] as String,
      ),
      relatedEntityId: data['relatedEntityId'] as String?,
      createdAt: _requiredDateTimeFromFirestore(data['createdAt']),
      updatedAt: _requiredDateTimeFromFirestore(data['updatedAt']),
    );
  }

  /// Converte o modelo para um mapa que pode ser salvo no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'name': name,
      'description': description,
      'sourceType': sourceType.name,
      'storagePath': storagePath,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      'externalUrl': externalUrl,
      'uploadedBy': uploadedBy,
      'relatedEntityType': relatedEntityType?.name,
      'relatedEntityId': relatedEntityId,
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
        'Uma data obrigatória do arquivo não foi encontrada.',
      );
    }

    return date;
  }
}
