import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stage_model.dart';

class StageFirestoreDataSource {
  final FirebaseFirestore firestore;

  StageFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _stages(
      String projectId,
      ) =>
      firestore
          .collection('projects')
          .doc(projectId)
          .collection('stages');

  Future<String> createStage(
      StageModel stage,
      ) async {
    final reference = _stages(stage.projectId).doc();


    await reference.set({
    ...stage.toFirestore(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    });

    return reference.id;


  }

  Future<StageModel?> getStage(
      String projectId,
      String stageId,
      ) async {
    final doc = await _stages(projectId).doc(stageId).get();


    if (!doc.exists) {
    return null;
    }

    return StageModel.fromFirestore(doc);


  }

  Future<List<StageModel>> getStagesForProject(
      String projectId,
      ) async {
    final snapshot = await _stages(projectId)
        .orderBy('order')
        .get();


    return snapshot.docs
        .map(StageModel.fromFirestore)
        .toList();


  }

  Future<void> updateStage(
      StageModel stage,
      ) async {
    await _stages(stage.projectId).doc(stage.id).update({
      'title': stage.title,
      'description': stage.description,
      'status': stage.status.name,
      'order': stage.order,
      'startDate': stage.startDate == null
          ? null
          : Timestamp.fromDate(stage.startDate!),
      'endDate': stage.endDate == null
          ? null
          : Timestamp.fromDate(stage.endDate!),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteStage(
      String projectId,
      String stageId,
      ) async {
    await _stages(projectId).doc(stageId).delete();
  }
}
