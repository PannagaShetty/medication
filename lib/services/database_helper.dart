import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:meta/meta.dart';
import '../models/medication.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;
  final String _databaseName;

  DatabaseHelper._init(this._databaseName);

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._init('medications.db');
    return _instance!;
  }

  @visibleForTesting
  factory DatabaseHelper.test() {
    return DatabaseHelper._init('test_medications.db');
  }

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
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
    await db.execute('''
      CREATE TABLE medications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        dosage INTEGER NOT NULL,
        reminderTimes TEXT NOT NULL,
        frequencyType TEXT NOT NULL,
        selectedDays TEXT NOT NULL,
        duration TEXT NOT NULL,
        hasAlarm INTEGER NOT NULL,
        snoozeTime TEXT,
        remainingQuantity INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return await db.insert('medications', medication.toMap());
  }

  Future<List<Medication>> getAllMedications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medications');
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  Future<int> updateMedication(Medication medication) async {
    final db = await database;
    return await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    final db = await database;
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    if (_database != null) {
      final db = await database;
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
