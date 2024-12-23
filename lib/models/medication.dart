import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 0)
class Medication {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> reminderTimes;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final int dosage;

  @HiveField(5)
  final String frequencyType;

  @HiveField(6)
  final List<int> selectedDays;

  @HiveField(7)
  final String duration;

  @HiveField(8)
  final bool hasAlarm;

  @HiveField(9)
  final String? snoozeTime;

  @HiveField(10)
  final int remainingQuantity;

  Medication({
    this.id,
    required this.name,
    required List<TimeOfDay> reminderTimes,
    required this.type,
    required this.dosage,
    required this.frequencyType,
    required this.selectedDays,
    required this.duration,
    required this.hasAlarm,
    this.snoozeTime,
    required this.remainingQuantity,
  }) : reminderTimes =
            reminderTimes.map((time) => '${time.hour}:${time.minute}').toList();

  List<TimeOfDay> get reminderTimesAsTimeOfDay {
    return reminderTimes.map((timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dosage': dosage,
      'reminderTimes': jsonEncode(reminderTimes),
      'frequencyType': frequencyType,
      'selectedDays': jsonEncode(selectedDays),
      'duration': duration,
      'hasAlarm': hasAlarm ? 1 : 0,
      'snoozeTime': snoozeTime,
      'remainingQuantity': remainingQuantity,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    final reminderTimesList = jsonDecode(map['reminderTimes']) as List;
    final List<TimeOfDay> times = reminderTimesList.map((timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }).toList();

    return Medication(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      dosage: map['dosage'],
      reminderTimes: times,
      frequencyType: map['frequencyType'],
      selectedDays: List<int>.from(jsonDecode(map['selectedDays'])),
      duration: map['duration'],
      hasAlarm: map['hasAlarm'] == 1,
      snoozeTime: map['snoozeTime'],
      remainingQuantity: map['remainingQuantity'],
    );
  }
}
