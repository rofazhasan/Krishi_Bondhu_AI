import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('krishi_bondhu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Crop reports table
    await db.execute('''
      CREATE TABLE crop_reports (
        id TEXT PRIMARY KEY,
        cropName TEXT NOT NULL,
        diseaseName TEXT NOT NULL,
        diseaseBanglaName TEXT NOT NULL,
        explanation TEXT NOT NULL,
        severity TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        treatmentOrganic TEXT NOT NULL,
        treatmentChemical TEXT NOT NULL
      )
    ''');
  }

  // Insert a report
  Future<int> insertReport(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(
      'crop_reports',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all reports sorted by date descending
  Future<List<Map<String, dynamic>>> queryAllReports() async {
    final db = await instance.database;
    return await db.query('crop_reports', orderBy: 'dateTime DESC');
  }

  // Delete a report
  Future<int> deleteReport(String id) async {
    final db = await instance.database;
    return await db.delete(
      'crop_reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear database (useful for reset)
  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('crop_reports');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
