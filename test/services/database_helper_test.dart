import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medication/models/medication.dart';
import 'package:medication/services/database_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late DatabaseHelper dbHelper;

  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicationAdapter());
  });

  setUp(() async {
    DatabaseHelper.resetInstance();
    dbHelper = DatabaseHelper.test();
    await dbHelper.deleteDatabase();
  });

  tearDown(() async {
    await dbHelper.close();
    await dbHelper.deleteDatabase();
  });

  group('DatabaseHelper CRUD Operations', () {
    test('should insert medication and return valid ID', () async {
      final medication = Medication(
        name: 'Test Med',
        type: 'Tablet',
        dosage: 1,
        reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
        frequencyType: 'Every Day',
        selectedDays: [1, 2, 3, 4, 5, 6, 7],
        duration: '1 Month',
        hasAlarm: true,
        snoozeTime: '5 min',
        remainingQuantity: 30,
      );

      final id = await dbHelper.insertMedication(medication);
      expect(id, isNotNull);

      final medications = await dbHelper.getAllMedications();
      expect(medications.length, 1);
      expect(medications[0].name, 'Test Med');
    });

    test('should retrieve empty list when no medications exist', () async {
      final medications = await dbHelper.getAllMedications();
      expect(medications, isEmpty);
    });

    test('should retrieve all medications', () async {
      final medications = [
        Medication(
          name: 'Med A',
          type: 'Tablet',
          dosage: 1,
          reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
          frequencyType: 'Every Day',
          selectedDays: [1, 2, 3, 4, 5, 6, 7],
          duration: '1 Month',
          hasAlarm: true,
          remainingQuantity: 30,
        ),
        Medication(
          name: 'Med B',
          type: 'Capsule',
          dosage: 2,
          reminderTimes: [const TimeOfDay(hour: 9, minute: 0)],
          frequencyType: 'Every Day',
          selectedDays: [1, 2, 3, 4, 5, 6, 7],
          duration: '2 Months',
          hasAlarm: false,
          remainingQuantity: 60,
        ),
      ];

      for (final med in medications) {
        await dbHelper.insertMedication(med);
      }

      final retrievedMeds = await dbHelper.getAllMedications();
      expect(retrievedMeds.length, 2);
      expect(retrievedMeds.map((m) => m.name), containsAll(['Med A', 'Med B']));
    });

    test('should update medication correctly', () async {
      final medication = Medication(
        name: 'Original Name',
        type: 'Tablet',
        dosage: 1,
        reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
        frequencyType: 'Every Day',
        selectedDays: [1, 2, 3, 4, 5, 6, 7],
        duration: '1 Month',
        hasAlarm: true,
        snoozeTime: '5 min',
        remainingQuantity: 30,
      );

      final id = await dbHelper.insertMedication(medication);

      final updatedMedication = Medication(
        id: id,
        name: 'Updated Name',
        type: 'Capsule',
        dosage: 2,
        reminderTimes: [const TimeOfDay(hour: 9, minute: 0)],
        frequencyType: 'Every Day',
        selectedDays: [1, 2, 3, 4, 5, 6, 7],
        duration: '2 Months',
        hasAlarm: false,
        remainingQuantity: 60,
      );

      await dbHelper.updateMedication(updatedMedication);

      final medications = await dbHelper.getAllMedications();
      expect(medications.length, 1);
      expect(medications[0].name, 'Updated Name');
      expect(medications[0].type, 'Capsule');
    });

    test('should delete medication correctly', () async {
      final medication = Medication(
        name: 'Test Med',
        type: 'Tablet',
        dosage: 1,
        reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
        frequencyType: 'Every Day',
        selectedDays: [1, 2, 3, 4, 5, 6, 7],
        duration: '1 Month',
        hasAlarm: true,
        snoozeTime: '5 min',
        remainingQuantity: 30,
      );

      final id = await dbHelper.insertMedication(medication);
      var medications = await dbHelper.getAllMedications();
      expect(medications.length, 1);

      await dbHelper.deleteMedication(id);
      medications = await dbHelper.getAllMedications();
      expect(medications.length, 0);
    });
  });
}
