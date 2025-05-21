// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChecklistAdapter extends TypeAdapter<Checklist> {
  @override
  final int typeId = 0;

  @override
  Checklist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Checklist(
      id: fields[0] as String,
      userId: fields[1] as String,
      teamName: fields[2] as String?,
      placeName: fields[3] as String,
      latitude: fields[4] as double,
      longitude: fields[5] as double,
      altitude: fields[6] as double?,
      accuracy: fields[7] as double?,
      date: fields[8] as DateTime,
      startTime: fields[9] as DateTime,
      endTime: fields[10] as DateTime,
      weather: fields[11] as String,
      comments: fields[12] as String?,
      isOpenAccess: fields[13] as bool,
      syncStatus: fields[14] as String,
      createdAt: fields[15] as DateTime?,
      updatedAt: fields[16] as DateTime?,
      observations: (fields[17] as List).cast<Observation>(),
    );
  }

  @override
  void write(BinaryWriter writer, Checklist obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.teamName)
      ..writeByte(3)
      ..write(obj.placeName)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.altitude)
      ..writeByte(7)
      ..write(obj.accuracy)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.startTime)
      ..writeByte(10)
      ..write(obj.endTime)
      ..writeByte(11)
      ..write(obj.weather)
      ..writeByte(12)
      ..write(obj.comments)
      ..writeByte(13)
      ..write(obj.isOpenAccess)
      ..writeByte(14)
      ..write(obj.syncStatus)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.observations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
