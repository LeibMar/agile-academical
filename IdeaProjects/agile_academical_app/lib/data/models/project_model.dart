import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.title,
    super.description,
    required super.status,
    required super.ownerId,
    super.advisorId,
    required super.memberIds,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      title: project.title,
      description: project.description,
      status: project.status,
      ownerId: project.ownerId,
      advisorId: project.advisorId,
      memberIds: List<String>.from(project.memberIds),
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
  }

  factory ProjectModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return ProjectModel(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      status: _statusFromString(data['status']),
      ownerId: data['ownerId'],
      advisorId: data['advisorId'],
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'ownerId': ownerId,
      'advisorId': advisorId,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static ProjectStatus _statusFromString(String value) {
    switch (value) {
      case 'inProgress':
        return ProjectStatus.inProgress;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      case 'planning':
      default:
        return ProjectStatus.planning;
    }
  }
}