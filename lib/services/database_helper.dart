import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import '../models/medication.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Box<Medication>? _box;
  final String _boxName;

  DatabaseHelper._init(this._boxName);

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._init('medications');
    return _instance!;
  }

  @visibleForTesting
  factory DatabaseHelper.test() {
    return DatabaseHelper._init('test_medications');
  }

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
    _box = null;
  }

  Future<Box<Medication>> get box async {
    if (_box != null) return _box!;
    _box = await _initBox(_boxName);
    return _box!;
  }

  Future<Box<Medication>> _initBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<Medication>(boxName);
    }
    return Hive.box<Medication>(boxName);
  }

  Future<int> insertMedication(Medication medication) async {
    final box = await this.box;
    final id = await box.add(medication);
    return id;
  }

  Future<List<Medication>> getAllMedications() async {
    final box = await this.box;
    return box.values.toList();
  }

  Future<int> updateMedication(Medication medication) async {
    final box = await this.box;
    await box.put(medication.id, medication);
    return medication.id!;
  }

  Future<void> deleteMedication(int id) async {
    final box = await this.box;
    await box.delete(id);
  }

  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  Future<void> deleteDatabase() async {
    await Hive.deleteBoxFromDisk(_boxName);
    _box = null;
  }
}
