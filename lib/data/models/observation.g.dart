// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObservationAdapter extends TypeAdapter<Observation> {
  @override
  final int typeId = 1;

  @override
  Observation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Observation(
      id: fields[0] as String,
      checklistId: fields[1] as String,
      taxonId: fields[2] as String?,
      customName: fields[3] as String?,
      individuals: fields[4] as int,
      lifeStage: fields[5] as String?,
      behavior: fields[6] as String?,
      remarks: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Observation obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.checklistId)
      ..writeByte(2)
      ..write(obj.taxonId)
      ..writeByte(3)
      ..write(obj.customName)
      ..writeByte(4)
      ..write(obj.individuals)
      ..writeByte(5)
      ..write(obj.lifeStage)
      ..writeByte(6)
      ..write(obj.behavior)
      ..writeByte(7)
      ..write(obj.remarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
