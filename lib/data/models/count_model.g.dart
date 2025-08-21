// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'count_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountModelAdapter extends TypeAdapter<CountModel> {
  @override
  final int typeId = 1;

  @override
  CountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountModel(
      id: fields[0] as int?,
      userId: fields[1] as String,
      team: fields[2] as String?,
      openAccess: fields[3] as bool,
      date: fields[4] as DateTime,
      startTime: fields[5] as DateTime?,
      endTime: fields[6] as DateTime?,
      latitude: fields[7] as double,
      longitude: fields[8] as double,
      altitude: fields[9] as double?,
      accuracy: fields[10] as double?,
      placeName: fields[11] as String?,
      districtId: fields[12] as String?,
      districtName: fields[13] as String?,
      stateName: fields[14] as String?,
      countryName: fields[15] as String?,
      distanceCovered: fields[16] as double?,
      weather: fields[17] as String?,
      notes: fields[18] as String?,
      version: fields[19] as String?,
      createdAt: fields[20] as DateTime?,
      updatedAt: fields[21] as DateTime?,
      observations: (fields[22] as List).cast<Observation>(),
    );
  }

  @override
  void write(BinaryWriter writer, CountModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.team)
      ..writeByte(3)
      ..write(obj.openAccess)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.latitude)
      ..writeByte(8)
      ..write(obj.longitude)
      ..writeByte(9)
      ..write(obj.altitude)
      ..writeByte(10)
      ..write(obj.accuracy)
      ..writeByte(11)
      ..write(obj.placeName)
      ..writeByte(12)
      ..write(obj.districtId)
      ..writeByte(13)
      ..write(obj.districtName)
      ..writeByte(14)
      ..write(obj.stateName)
      ..writeByte(15)
      ..write(obj.countryName)
      ..writeByte(16)
      ..write(obj.distanceCovered)
      ..writeByte(17)
      ..write(obj.weather)
      ..writeByte(18)
      ..write(obj.notes)
      ..writeByte(19)
      ..write(obj.version)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt)
      ..writeByte(22)
      ..write(obj.observations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountModel _$CountModelFromJson(Map<String, dynamic> json) => CountModel(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String,
      team: json['team'] as String?,
      openAccess: json['open_access'] as bool,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      placeName: json['place_name'] as String?,
      districtId: json['district_id'] as String?,
      districtName: json['district_name'] as String?,
      stateName: json['state_name'] as String?,
      countryName: json['country_name'] as String?,
      distanceCovered: (json['distance_covered'] as num?)?.toDouble(),
      weather: json['weather'] as String?,
      notes: json['notes'] as String?,
      version: json['version'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      observations: (json['observations'] as List<dynamic>)
          .map((e) => Observation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CountModelToJson(CountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'team': instance.team,
      'open_access': instance.openAccess,
      'date': instance.date.toIso8601String(),
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'accuracy': instance.accuracy,
      'place_name': instance.placeName,
      'district_id': instance.districtId,
      'district_name': instance.districtName,
      'state_name': instance.stateName,
      'country_name': instance.countryName,
      'distance_covered': instance.distanceCovered,
      'weather': instance.weather,
      'notes': instance.notes,
      'version': instance.version,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'observations': instance.observations,
    };
