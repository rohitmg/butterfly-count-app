// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'count_model.dart';

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
    };
