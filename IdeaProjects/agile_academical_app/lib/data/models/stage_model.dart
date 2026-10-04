import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/stage.dart';

class StageModel extends Stage {
  const StageModel({
    required super.id,
    required super.projectId,
    required super.title,
    super.description,
    required super.status,
    required super.order,
    super.startDate,
    super.endDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StageModel.fromEntity(Stage stage) {
    return StageModel(
      id: stage.id,
      projectId: stage.projectId,
      title: stage.title,
      description: stage.description,
      status: stage.status,
      order: stage.order,
      startDate: stage.startDate,
      endDate: stage.endDate,
      createdAt: stage.createdAt,
      updatedAt: stage.updatedAt,
    );
  }

  factory StageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();


    if (data == null) {
    throw StateError(
    'Documento da etapa ${doc.id} não possui dados.',
    );
    }

    return StageModel(
    id: doc.id,
    projectId: data['projectId'] as String,
    title: data['title'] as String,
    description: data['description'] as String?,
    status: StageStatus.values.firstWhere(
    (status) => status.name == data['status'],
    orElse: () => StageStatus.planning,
    ),
    order: (data['order'] as num).toInt(),
    startDate: _dateFromFirestore(data['startDate']),
    endDate: _dateFromFirestore(data['endDate']),
    createdAt: _dateFromFirestore(data['createdAt'])!,
    updatedAt: _dateFromFirestore(data['updatedAt'])!,
    );


    }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status.name,
      'order': order,
      'startDate': startDate == null
          ? null
          : Timestamp.fromDate(startDate!),
      'endDate': endDate == null
          ? null
          : Timestamp.fromDate(endDate!),
    };
  }

  static DateTime? _dateFromFirestore(dynamic value) {
    if (value == null) {
      return null;
    }


    if (value is Timestamp) {
    return value.toDate();
    }

    if (value is DateTime) {
    return value;
    }

    throw StateError(
    'Valor de data inválido no Firestore: $value',
    );


  }
}
