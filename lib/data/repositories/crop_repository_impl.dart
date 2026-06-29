import '../../core/database/database_helper.dart';
import '../../domain/models/crop_report.dart';
import '../../domain/repositories/crop_repository.dart';

class CropRepositoryImpl implements CropRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> saveReport(CropReport report) async {
    await _dbHelper.insertReport(report.toMap());
  }

  @override
  Future<List<CropReport>> getSavedReports() async {
    final rawReports = await _dbHelper.queryAllReports();
    return rawReports.map((map) => CropReport.fromMap(map)).toList();
  }

  @override
  Future<void> deleteReport(String id) async {
    await _dbHelper.deleteReport(id);
  }

  @override
  Future<void> clearAllReports() async {
    await _dbHelper.clearAll();
  }
}
