import '../../domain/entities/stage.dart';
import '../../domain/repositories/stage_repository.dart';
import '../datasources/stage_firestore_datasource.dart';
import '../models/stage_model.dart';

class StageRepositoryImpl implements StageRepository {
  final StageFirestoreDataSource dataSource;

  StageRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<String> createStage(Stage stage) {
    final model = StageModel.fromEntity(stage);


    return dataSource.createStage(model);


  }

  @override
  Future<Stage?> getStage(
      String projectId,
      String stageId,
      ) {
    return dataSource.getStage(
      projectId,
      stageId,
    );
  }

  @override
  Future<List<Stage>> getStagesForProject(
      String projectId,
      ) {
    return dataSource.getStagesForProject(projectId);
  }

  @override
  Future<void> updateStage(Stage stage) {
    final model = StageModel.fromEntity(stage);


    return dataSource.updateStage(model);


  }

  @override
  Future<void> deleteStage(
      String projectId,
      String stageId,
      ) {
    return dataSource.deleteStage(
      projectId,
      stageId,
    );
  }
}
