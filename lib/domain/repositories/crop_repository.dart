import '../models/crop_report.dart';

abstract class CropRepository {
  Future<void> saveReport(CropReport report);
  Future<List<CropReport>> getSavedReports();
  Future<void> deleteReport(String id);
  Future<void> clearAllReports();
}
