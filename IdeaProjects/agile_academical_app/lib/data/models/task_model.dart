
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.projectId,
    super.stageId,
    required super.title,
    super.description,
    required super.status,
    required super.priority,
    super.assignedTo,
    required super.createdBy,
    super.startDate,
    super.dueDate,
    super.completedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Converte a entidade Task para o modelo concreto.
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      projectId: task.projectId,
      stageId: task.stageId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assignedTo: task.assignedTo,
      createdBy: task.createdBy,
      startDate: task.startDate,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  /// Constrói o modelo a partir de um documento do Firestore.
  factory TaskModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    if (data == null) {
      throw StateError(
        'Não foi possível ler a tarefa: documento ${doc.id} sem dados.',
      );
    }

    return TaskModel(
      id: doc.id,
      projectId: data['projectId'] as String,
      stageId: data['stageId'] as String?,
      title: data['title'] as String,
      description: data['description'] as String?,
      status: TaskStatus.values.byName(data['status'] as String),
      priority: TaskPriority.values.byName(data['priority'] as String),
      assignedTo: data['assignedTo'] as String?,
      createdBy: data['createdBy'] as String,
      startDate: _dateTimeFromFirestore(data['startDate']),
      dueDate: _dateTimeFromFirestore(data['dueDate']),
      completedAt: _dateTimeFromFirestore(data['completedAt']),
      createdAt: _requiredDateTimeFromFirestore(data['createdAt']),
      updatedAt: _requiredDateTimeFromFirestore(data['updatedAt']),
    );
  }

  /// Converte o modelo para um mapa que pode ser salvo no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'stageId': stageId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'startDate': startDate,
      'dueDate': dueDate,
      'completedAt': completedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime? _dateTimeFromFirestore(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    throw FormatException(
      'Tipo de data não suportado no Firestore: ${value.runtimeType}',
    );
  }

  static DateTime _requiredDateTimeFromFirestore(dynamic value) {
    final date = _dateTimeFromFirestore(value);

    if (date == null) {
      throw const FormatException(
        'Uma data obrigatória da tarefa não foi encontrada.',
      );
    }

    return date;
  }
}
