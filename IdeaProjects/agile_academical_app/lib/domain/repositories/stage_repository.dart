import '../entities/stage.dart';

abstract class StageRepository {
  Future<String> createStage(Stage stage);

  Future<Stage?> getStage(
      String projectId,
      String stageId,
      );

  Future<List<Stage>> getStagesForProject(
      String projectId,
      );

  Future<void> updateStage(Stage stage);

  Future<void> deleteStage(
      String projectId,
      String stageId,
      );
}
