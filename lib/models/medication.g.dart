// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 0;

  @override
  Medication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medication(
      id: fields[0] as int?,
      name: fields[1] as String,
      reminderTimes: (fields[2] as List).cast<TimeOfDay>(),
      type: fields[3] as String,
      dosage: fields[4] as int,
      frequencyType: fields[5] as String,
      selectedDays: (fields[6] as List).cast<int>(),
      duration: fields[7] as String,
      hasAlarm: fields[8] as bool,
      snoozeTime: fields[9] as String?,
      remainingQuantity: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.reminderTimes)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.dosage)
      ..writeByte(5)
      ..write(obj.frequencyType)
      ..writeByte(6)
      ..write(obj.selectedDays)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.hasAlarm)
      ..writeByte(9)
      ..write(obj.snoozeTime)
      ..writeByte(10)
      ..write(obj.remainingQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
