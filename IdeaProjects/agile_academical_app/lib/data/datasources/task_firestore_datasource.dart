
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class TaskFirestoreDataSource {
  final FirebaseFirestore firestore;

  TaskFirestoreDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksCollection(
      String projectId,
      ) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks');
  }

  /// Cria uma tarefa e retorna o ID gerado pelo Firestore.
  Future<String> createTask(TaskModel task) async {
    final docRef = _tasksCollection(task.projectId).doc();

    final data = task.toFirestore()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);

    return docRef.id;
  }

  /// Busca uma tarefa pelo projeto e pelo ID do documento.
  /// Retorna null caso o documento não exista.
  Future<TaskModel?> getTask(
      String projectId,
      String taskId,
      ) async {
    final doc = await _tasksCollection(projectId).doc(taskId).get();

    if (!doc.exists) {
      return null;
    }

    return TaskModel.fromFirestore(doc);
  }

  /// Lista as tarefas de um projeto, da mais recente para a mais antiga.
  Future<List<TaskModel>> getTasksForProject(
      String projectId,
      ) async {
    final snapshot = await _tasksCollection(projectId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();
  }

  /// Atualiza uma tarefa sem alterar sua data de criação.
  Future<void> updateTask(TaskModel task) async {
    final data = task.toFirestore();

    data.remove('createdAt');
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _tasksCollection(task.projectId)
        .doc(task.id)
        .update(data);
  }

  /// Exclui uma tarefa do projeto.
  Future<void> deleteTask(
      String projectId,
      String taskId,
      ) async {
    await _tasksCollection(projectId).doc(taskId).delete();
  }
}
