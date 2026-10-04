import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project.dart';
import '../models/project_model.dart';

class ProjectFirestoreDataSource {
  final FirebaseFirestore firestore;

  ProjectFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _projects =>
      firestore.collection('projects');

  Future<String> createProject(ProjectModel project) async {
    final reference = _projects.doc();

    await reference.set({
      ...project.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }

  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _projects.doc(projectId).get();

    if (!doc.exists) {
      return null;
    }

    return ProjectModel.fromFirestore(doc);
  }

  Future<List<ProjectModel>> getProjectsForUser(
      String uid,
      ) async {
    final snapshot = await _projects
        .where('memberIds', arrayContains: uid)
        .get();

    return snapshot.docs
        .map(ProjectModel.fromFirestore)
        .toList();
  }

  Future<void> updateProject(ProjectModel project) async {
    await _projects.doc(project.id).update({
      'title': project.title,
      'description': project.description,
      'status': project.status.name,
      'ownerId': project.ownerId,
      'advisorId': project.advisorId,
      'memberIds': project.memberIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addMember(
      String projectId,
      String uid,
      ) async {
    await _projects.doc(projectId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeMember(
      String projectId,
      String uid,
      ) async {
    await _projects.doc(projectId).update({
      'memberIds': FieldValue.arrayRemove([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelProject(String projectId) async {
    await _projects.doc(projectId).update({
      'status': ProjectStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProject(String projectId) async {
    final projectReference = _projects.doc(projectId);

    final stagesSnapshot =
    await projectReference.collection('stages').get();

    final batch = firestore.batch();

    for (final stage in stagesSnapshot.docs) {
      batch.delete(stage.reference);
    }

    batch.delete(projectReference);

    await batch.commit();
  }
}