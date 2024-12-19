import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medication/models/medication.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([])
void main() {
  group('Medication Model', () {
    test('should create a Medication instance with all required fields', () {
      final medication = Medication(
        name: 'Aspirin',
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

      expect(medication.name, 'Aspirin');
      expect(medication.type, 'Tablet');
      expect(medication.dosage, 1);
      expect(medication.reminderTimes.length, 1);
      expect(medication.reminderTimes[0].hour, 8);
      expect(medication.reminderTimes[0].minute, 0);
      expect(medication.frequencyType, 'Every Day');
      expect(medication.selectedDays, [1, 2, 3, 4, 5, 6, 7]);
      expect(medication.duration, '1 Month');
      expect(medication.hasAlarm, true);
      expect(medication.snoozeTime, '5 min');
      expect(medication.remainingQuantity, 30);
    });

    test('should handle empty reminder times list', () {
      final medication = Medication(
        name: 'Test Med',
        type: 'Tablet',
        dosage: 1,
        reminderTimes: [],
        frequencyType: 'Every Day',
        selectedDays: [1],
        duration: '1 Week',
        hasAlarm: false,
        remainingQuantity: 7,
      );

      final map = medication.toMap();
      expect(map['reminderTimes'], '[]');

      final recreatedMedication = Medication.fromMap(map);
      expect(recreatedMedication.reminderTimes, isEmpty);
    });

    test(
        'should handle multiple reminder times with different hours and minutes',
        () {
      final medication = Medication(
        name: 'Test Med',
        type: 'Tablet',
        dosage: 3,
        reminderTimes: [
          const TimeOfDay(hour: 8, minute: 15),
          const TimeOfDay(hour: 14, minute: 30),
          const TimeOfDay(hour: 20, minute: 45),
        ],
        frequencyType: 'Every Day',
        selectedDays: [1, 2, 3, 4, 5],
        duration: '2 Weeks',
        hasAlarm: true,
        snoozeTime: '10 min',
        remainingQuantity: 42,
      );

      final map = medication.toMap();
      expect(map['reminderTimes'], '["8:15","14:30","20:45"]');

      final recreatedMedication = Medication.fromMap(map);
      expect(recreatedMedication.reminderTimes.length, 3);
      expect(recreatedMedication.reminderTimes[0].hour, 8);
      expect(recreatedMedication.reminderTimes[0].minute, 15);
      expect(recreatedMedication.reminderTimes[1].hour, 14);
      expect(recreatedMedication.reminderTimes[1].minute, 30);
      expect(recreatedMedication.reminderTimes[2].hour, 20);
      expect(recreatedMedication.reminderTimes[2].minute, 45);
    });

    test('should handle custom selected days', () {
      final medication = Medication(
        name: 'Test Med',
        type: 'Tablet',
        dosage: 1,
        reminderTimes: [const TimeOfDay(hour: 9, minute: 0)],
        frequencyType: 'Custom Days',
        selectedDays: [2, 4, 6], // Tuesday, Thursday, Saturday
        duration: '1 Month',
        hasAlarm: true,
        snoozeTime: '5 min',
        remainingQuantity: 12,
      );

      final map = medication.toMap();
      expect(map['selectedDays'], '[2,4,6]');

      final recreatedMedication = Medication.fromMap(map);
      expect(recreatedMedication.selectedDays, [2, 4, 6]);
      expect(recreatedMedication.frequencyType, 'Custom Days');
    });

    test('should handle null ID in toMap', () {
      final medication = Medication(
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

      final map = medication.toMap();
      expect(map['id'], null);
    });

    test('should handle all medication types', () {
      final types = ['Tablet', 'Capsule', 'Drops', 'Injection'];

      for (final type in types) {
        final medication = Medication(
          name: 'Test Med',
          type: type,
          dosage: 1,
          reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
          frequencyType: 'Every Day',
          selectedDays: [1],
          duration: '1 Week',
          hasAlarm: true,
          remainingQuantity: 7,
        );

        final map = medication.toMap();
        expect(map['type'], type);

        final recreatedMedication = Medication.fromMap(map);
        expect(recreatedMedication.type, type);
      }
    });

    test('should handle all duration options', () {
      final durations = ['1 Week', '2 Weeks', '1 Month', '3 Months'];

      for (final duration in durations) {
        final medication = Medication(
          name: 'Test Med',
          type: 'Tablet',
          dosage: 1,
          reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
          frequencyType: 'Every Day',
          selectedDays: [1],
          duration: duration,
          hasAlarm: true,
          remainingQuantity: 7,
        );

        final map = medication.toMap();
        expect(map['duration'], duration);

        final recreatedMedication = Medication.fromMap(map);
        expect(recreatedMedication.duration, duration);
      }
    });
  });
}
