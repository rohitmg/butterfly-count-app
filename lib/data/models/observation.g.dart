// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation.dart';

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
