// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObservationAdapter extends TypeAdapter<Observation> {
  @override
  final int typeId = 2;

  @override
  Observation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Observation(
      id: fields[0] as int?,
      countId: fields[1] as int,
      userId: fields[2] as String,
      taxaId: fields[3] as String,
      taxaCommonName: fields[4] as String?,
      taxaScientificName: fields[5] as String?,
      individuals: fields[6] as int,
      activity: fields[7] as String?,
      notes: fields[8] as String?,
      timestamp: fields[9] as DateTime,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Observation obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.countId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.taxaId)
      ..writeByte(4)
      ..write(obj.taxaCommonName)
      ..writeByte(5)
      ..write(obj.taxaScientificName)
      ..writeByte(6)
      ..write(obj.individuals)
      ..writeByte(7)
      ..write(obj.activity)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.timestamp)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Observation _$ObservationFromJson(Map<String, dynamic> json) => Observation(
      id: (json['id'] as num?)?.toInt(),
      countId: (json['count_id'] as num).toInt(),
      userId: json['user_id'] as String,
      taxaId: json['taxa_id'] as String,
      taxaCommonName: json['taxa_common_name'] as String?,
      taxaScientificName: json['taxa_scientific_name'] as String?,
      individuals: (json['individuals'] as num).toInt(),
      activity: json['activity'] as String?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ObservationToJson(Observation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'count_id': instance.countId,
      'user_id': instance.userId,
      'taxa_id': instance.taxaId,
      'taxa_common_name': instance.taxaCommonName,
      'taxa_scientific_name': instance.taxaScientificName,
      'individuals': instance.individuals,
      'activity': instance.activity,
      'notes': instance.notes,
      'timestamp': instance.timestamp.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
