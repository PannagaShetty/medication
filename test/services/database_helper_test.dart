import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medication/models/medication.dart';
import 'package:medication/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite/sqflite.dart' show databaseFactory;

void main() {
  late DatabaseHelper dbHelper;

  setUpAll(() {
    // Initialize FFI
    sqflite_ffi.sqfliteFfiInit();
    // Change the default factory for testing
    databaseFactory = sqflite_ffi.databaseFactoryFfi;
  });

  setUp(() async {
    // Reset the database helper instance before each test
    DatabaseHelper.resetInstance();
    // Create a new test database instance
    dbHelper = DatabaseHelper.test();
    try {
      // Ensure any existing test database is deleted
      await dbHelper.deleteDatabase();
    } catch (e) {
      // Ignore errors if database doesn't exist
    }
  });

  tearDown(() async {
    try {
      // Clean up after each test
      await dbHelper.close();
      await dbHelper.deleteDatabase();
    } catch (e) {
      // Ignore cleanup errors
    }
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
      expect(id, 1); // First inserted record should have id 1

      final medications = await dbHelper.getAllMedications();
      expect(medications.length, 1);
      expect(medications[0].id, 1);
      expect(medications[0].name, 'Test Med');
    });

    test('should retrieve empty list when no medications exist', () async {
      final medications = await dbHelper.getAllMedications();
      expect(medications, isEmpty);
    });

    test('should retrieve all medications in correct order', () async {
      // Insert test medications
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
        Medication(
          name: 'Med C',
          type: 'Drops',
          dosage: 3,
          reminderTimes: [const TimeOfDay(hour: 10, minute: 0)],
          frequencyType: 'Every Day',
          selectedDays: [1, 2, 3, 4, 5, 6, 7],
          duration: '3 Months',
          hasAlarm: true,
          remainingQuantity: 90,
        ),
      ];

      for (final med in medications) {
        await dbHelper.insertMedication(med);
      }

      final retrievedMeds = await dbHelper.getAllMedications();
      expect(retrievedMeds.length, 3);
      expect(retrievedMeds[0].name, 'Med A');
      expect(retrievedMeds[1].name, 'Med B');
      expect(retrievedMeds[2].name, 'Med C');
    });

    test('should update medication correctly', () async {
      // Insert initial medication
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

      // Create updated version
      final updatedMedication = Medication(
        id: id,
        name: 'Updated Name',
        type: 'Capsule',
        dosage: 2,
        reminderTimes: [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 21, minute: 0),
        ],
        frequencyType: 'Custom Days',
        selectedDays: [2, 4, 6],
        duration: '2 Months',
        hasAlarm: false,
        remainingQuantity: 60,
      );

      final rowsAffected = await dbHelper.updateMedication(updatedMedication);
      expect(rowsAffected, 1);

      final medications = await dbHelper.getAllMedications();
      expect(medications.length, 1);
      expect(medications[0].name, 'Updated Name');
      expect(medications[0].type, 'Capsule');
      expect(medications[0].dosage, 2);
      expect(medications[0].reminderTimes.length, 2);
      expect(medications[0].frequencyType, 'Custom Days');
      expect(medications[0].selectedDays, [2, 4, 6]);
      expect(medications[0].hasAlarm, false);
      expect(medications[0].snoozeTime, null);
    });

    test('should handle updating non-existent medication', () async {
      final nonExistentMedication = Medication(
        id: 999, // Non-existent ID
        name: 'Test Med',
        type: 'Tablet',
        dosage: 1,
        reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
        frequencyType: 'Every Day',
        selectedDays: [1],
        duration: '1 Week',
        hasAlarm: true,
        remainingQuantity: 7,
      );

      final rowsAffected =
          await dbHelper.updateMedication(nonExistentMedication);
      expect(rowsAffected, 0); // No rows should be affected
    });

    test('should delete medication correctly', () async {
      // Insert a medication
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

      // Verify medication was inserted
      var medications = await dbHelper.getAllMedications();
      expect(medications.length, 1);

      // Delete the medication
      final rowsAffected = await dbHelper.deleteMedication(id);
      expect(rowsAffected, 1);

      // Verify medication was deleted
      medications = await dbHelper.getAllMedications();
      expect(medications.length, 0);
    });

    test('should handle deleting non-existent medication', () async {
      final rowsAffected =
          await dbHelper.deleteMedication(999); // Non-existent ID
      expect(rowsAffected, 0); // No rows should be affected
    });

    test('should handle multiple reminder times and custom days', () async {
      final medication = Medication(
        name: 'Complex Med',
        type: 'Tablet',
        dosage: 3,
        reminderTimes: [
          const TimeOfDay(hour: 8, minute: 15),
          const TimeOfDay(hour: 14, minute: 30),
          const TimeOfDay(hour: 20, minute: 45),
        ],
        frequencyType: 'Custom Days',
        selectedDays: [2, 4, 6], // Tuesday, Thursday, Saturday
        duration: '1 Month',
        hasAlarm: true,
        snoozeTime: '10 min',
        remainingQuantity: 90,
      );

      final id = await dbHelper.insertMedication(medication);
      final medications = await dbHelper.getAllMedications();

      expect(medications.length, 1);
      final savedMed = medications[0];
      expect(savedMed.id, id);
      expect(savedMed.reminderTimes.length, 3);
      expect(savedMed.reminderTimes[0].hour, 8);
      expect(savedMed.reminderTimes[0].minute, 15);
      expect(savedMed.reminderTimes[1].hour, 14);
      expect(savedMed.reminderTimes[1].minute, 30);
      expect(savedMed.reminderTimes[2].hour, 20);
      expect(savedMed.reminderTimes[2].minute, 45);
      expect(savedMed.selectedDays, [2, 4, 6]);
    });
  });
}
