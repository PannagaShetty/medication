import 'dart:convert';
import 'package:flutter/material.dart';

class Medication {
  final int? id;
  final String name;
  final List<TimeOfDay> reminderTimes;
  final String type;
  final int dosage;
  final String frequencyType;
  final List<int> selectedDays;
  final String duration;
  final bool hasAlarm;
  final String? snoozeTime;
  final int remainingQuantity;

  Medication({
    this.id,
    required this.name,
    required this.reminderTimes,
    required this.type,
    required this.dosage,
    required this.frequencyType,
    required this.selectedDays,
    required this.duration,
    required this.hasAlarm,
    this.snoozeTime,
    required this.remainingQuantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dosage': dosage,
      'reminderTimes': jsonEncode(
        reminderTimes.map((time) => '${time.hour}:${time.minute}').toList(),
      ),
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
